extends Node
class_name AudioManager

# Lives in Main, so it survives every scene change.
#	Music:	Globals.audioManager.playMusic(Audio.MusicType.game)
#			Every MusicType has a folder: res://Systems/Audio/Music/<Type>/ (Menu, Game, Pause).
#			Drop any number of .ogg / .mp3 / .wav files in there. The tracks play in random order
#			(every track once before any repeats) and each one crossfades into the next before it ends.
#	UI:		Globals.audioManager.playSfx2D(Audio.SfxType.uiClick)
# Sounds in the world (3D, directional) go through the SFXManager inside the World.


#region Enums

enum PauseBehavior {
	silence, # The music fades out and is paused, it continues exactly where it stopped
	track,   # The music crossfades to MusicType.pause and back afterwards
}

#endregion


#region Constants

const MASTER_BUS := &"Master"
const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"

const SILENT_DB := -80.0
const UI_POOL_SIZE := 8

const MUSIC_EXTENSIONS : PackedStringArray = ["ogg", "mp3", "wav"]

#endregion


#region Exported variables

@export_group("Music")
## Folder that contains one subfolder per MusicType (Menu, Game, Pause)
@export_dir var MUSIC_ROOT : String = "res://Systems/Audio/Music"
## Crossfade when the game state changes (menu -> game ...)
@export var CROSSFADE_TIME : float = 1.0
## Crossfade from one track into the next one of the same folder. It starts this many seconds before the track ends.
@export var TRACK_CROSSFADE_TIME : float = 4.0
## Volume of all music tracks, on top of the music slider in the settings
@export_range(-40.0, 6.0) var MUSIC_VOLUME_DB : float = -6.0
@export var PAUSE_BEHAVIOR : PauseBehavior = PauseBehavior.silence
@export var PAUSE_FADE_TIME : float = 0.4

@export_group("UI sounds")
@export var SFX_DATASET : SfxDataset = null

#endregion


#region Member variables

# Music
var _musicPlayers : Array[AudioStreamPlayer] = []
var _activePlayer : int = 0
var _currentType : Audio.MusicType = Audio.MusicType.none
var _resume : Dictionary = {}    # MusicType -> { "path": String, "position": float }, used to resume a track
var _tweens : Dictionary = {}    # AudioStreamPlayer -> running fade
var _currentPath : String = ""   # Track that plays right now
var _bags : Dictionary = {}      # MusicType -> Array[String], tracks that have not been played in this round
var _lastPath : Dictionary = {}  # MusicType -> last picked track, so a new round never starts with it
var _advancing : bool = false    # The next track has already been started

var _inPause : bool = false
var _pausedType : Audio.MusicType = Audio.MusicType.none

# UI sounds
var _uiPlayers : Array[AudioStreamPlayer] = []
var _uiNext : int = 0
var _lastPlayed : Dictionary = {} # SfxType -> msec

# Volumes
var _volumesApplied : bool = false
var _masterSilent : bool = false
var _focusLost : bool = false

#endregion


#region Built-in functions

func _ready() -> void:
	if Globals.audioManager != null:
		push_error("AudioManager._ready(): AudioManager has already been initialized once!")
		return

	Globals.audioManager = self
	process_mode = Node.PROCESS_MODE_ALWAYS # Music keeps going while the world is disabled

	for i in 2:
		var player := AudioStreamPlayer.new()
		player.bus = MUSIC_BUS
		player.volume_db = SILENT_DB
		player.finished.connect(_onMusicFinished.bind(player))
		add_child(player)
		_musicPlayers.push_back(player)

	for i in UI_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_uiPlayers.push_back(player)


func _process(_delta : float) -> void:
	_watchTrackEnd()


func _exit_tree() -> void:
	if Globals.audioManager == self:
		Globals.audioManager = null


func _notification(what : int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			_focusLost = true
			_refreshMasterMute()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			_focusLost = false
			_refreshMasterMute()

#endregion


#region Public functions: music

# resume = continue the track where it was left the last time instead of starting a new one
func playMusic(type : Audio.MusicType, resume : bool = false) -> void:
	_applyVolumesOnce()

	_inPause = false
	_pausedType = Audio.MusicType.none

	if type == Audio.MusicType.none:
		stopMusic()
		return

	var current := _musicPlayers[_activePlayer]
	if type == _currentType and _alive(current):
		if current.stream_paused: # Same state was paused: just continue it
			_unpause(current)
		return

	var path := ""
	var start := 0.0
	if resume and _resume.has(type):
		var saved : Dictionary = _resume[type]
		path = saved["path"]
		start = saved["position"]

	if path.is_empty():
		path = _pickTrack(type)
		start = 0.0

	var stream := _loadTrack(path)
	if stream == null:
		push_warning("AudioManager.playMusic(): No music found for '%s' in '%s'." % [Audio.MusicType.keys()[type], _folder(type)])
		return

	if start >= stream.get_length() - 0.5:
		start = 0.0

	_crossfadeTo(type, path, stream, start, CROSSFADE_TIME)


func stopMusic(fadeTime : float = -1.0) -> void:
	_inPause = false
	_pausedType = Audio.MusicType.none

	_retire(_musicPlayers[_activePlayer], _currentType, CROSSFADE_TIME if fadeTime < 0.0 else fadeTime)
	_currentType = Audio.MusicType.none
	_currentPath = ""


# Call when the game gets paused / unpaused. What happens depends on PAUSE_BEHAVIOR.
func enterPause() -> void:
	if _inPause:
		return

	_inPause = true
	_pausedType = _currentType

	if PAUSE_BEHAVIOR == PauseBehavior.track and _currentType != Audio.MusicType.pause:
		var path := _pickTrack(Audio.MusicType.pause)
		var stream := _loadTrack(path)
		if stream != null:
			_crossfadeTo(Audio.MusicType.pause, path, stream, 0.0, CROSSFADE_TIME)
			return

	# Silence (also the fallback when there is no pause track)
	var current := _musicPlayers[_activePlayer]
	if current.playing and not current.stream_paused:
		_fadeTo(current, SILENT_DB, PAUSE_FADE_TIME, func() -> void: current.stream_paused = true)


func exitPause() -> void:
	if not _inPause:
		return

	var type := _pausedType
	_inPause = false
	_pausedType = Audio.MusicType.none

	if _currentType == Audio.MusicType.pause:
		# The pause track is playing: go back to what was playing before
		if type == Audio.MusicType.none:
			stopMusic()
		else:
			playMusic(type, true)
		return

	var current := _musicPlayers[_activePlayer]
	if _alive(current):
		_unpause(current)


func currentMusic() -> Audio.MusicType:
	return _currentType


# File name of the track that plays right now (for debugging or a "now playing" display)
func currentTrack() -> String:
	return _currentPath.get_file()

#endregion


#region Public functions: UI sounds

# Non-positional sound, e.g. for menus. Sounds in the world use the SFXManager.
func playSfx2D(type : Audio.SfxType) -> void:
	if SFX_DATASET == null:
		return

	var data := SFX_DATASET.DATASET.get(type) as SoundData
	if data == null or data.STREAMS.is_empty():
		push_warning("AudioManager.playSfx2D(): No sound registered for '%s'." % Audio.SfxType.keys()[type])
		return

	var now := Time.get_ticks_msec()
	if data.COOLDOWN > 0.0 and now - _lastPlayed.get(type, -1000000) < data.COOLDOWN * 1000.0:
		return
	_lastPlayed[type] = now

	var player := _uiPlayers[_uiNext]
	_uiNext = (_uiNext + 1) % _uiPlayers.size() # Round robin, the oldest sound gets replaced

	player.stream = data.pick()
	player.volume_db = data.VOLUME_DB
	player.pitch_scale = data.randomPitch()
	player.play()

#endregion


#region Public functions: volumes

# Reads the audio section of the settings and sets the buses. Called by SettingsManager.applyAudioSettings().
func applyVolumes() -> void:
	var settings := Globals.settingsManager
	if settings == null:
		return

	_setBusVolume(MUSIC_BUS, settings.getFloat("audio", "music"))
	_setBusVolume(SFX_BUS, settings.getFloat("audio", "sfx"))

	var master := settings.getFloat("audio", "master")
	_setBusVolume(MASTER_BUS, master)
	_masterSilent = master < 0.001
	_refreshMasterMute()

	_volumesApplied = true

#endregion


#region Private functions: music

func _folder(type : Audio.MusicType) -> String:
	return MUSIC_ROOT.path_join(String(Audio.MusicType.keys()[type]).capitalize())


# All tracks in the folder of a type. Works in the editor and in exported games
# (there the files are listed with an extra ".import" / ".remap" ending that has to be removed).
func _scan(type : Audio.MusicType) -> Array[String]:
	var folder := _folder(type)
	var found : Dictionary = {}

	for file in DirAccess.get_files_at(folder):
		var fileName := file
		if fileName.ends_with(".import"):
			fileName = fileName.trim_suffix(".import")
		elif fileName.ends_with(".remap"):
			fileName = fileName.trim_suffix(".remap")

		if fileName.get_extension().to_lower() in MUSIC_EXTENSIONS:
			found[folder.path_join(fileName)] = true

	var result : Array[String] = []
	result.assign(found.keys())
	result.sort()
	return result


# Random order, every track once before any track is repeated. The first track of a new round is never the last one of the old round.
func _pickTrack(type : Audio.MusicType) -> String:
	var bag : Array[String] = _bags.get(type, [] as Array[String])

	if bag.is_empty():
		bag = _scan(type)
		if bag.is_empty():
			return ""

		bag.shuffle()
		var last : String = _lastPath.get(type, "")
		if bag.size() > 1 and bag[0] == last:
			bag.push_back(bag.pop_front())

	var path : String = bag.pop_front()
	_bags[type] = bag
	_lastPath[type] = path
	return path


func _loadTrack(path : String) -> AudioStream:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null

	var stream := load(path) as AudioStream
	if stream == null:
		push_warning("AudioManager: '%s' is not an audio file." % path)
		return null

	_disableLoop(stream) # A looping track would never end, so it could never go over to the next one
	return stream


func _crossfadeTo(type : Audio.MusicType, path : String, stream : AudioStream, start : float, time : float) -> void:
	var fade := minf(time, stream.get_length() * 0.5)

	var oldPlayer := _musicPlayers[_activePlayer]
	var oldType := _currentType

	_activePlayer = 1 - _activePlayer
	var newPlayer := _musicPlayers[_activePlayer]

	_retire(oldPlayer, oldType, fade)

	_killTween(newPlayer)
	newPlayer.stream = stream
	newPlayer.stream_paused = false
	newPlayer.volume_db = SILENT_DB if fade > 0.0 else MUSIC_VOLUME_DB
	newPlayer.play(start)

	if fade > 0.0:
		_fadeTo(newPlayer, MUSIC_VOLUME_DB, fade)

	_currentType = type
	_currentPath = path
	_advancing = false


# Starts the next track of the same folder while the current one is still playing its last seconds
func _watchTrackEnd() -> void:
	if _advancing or _currentType == Audio.MusicType.none:
		return

	var player := _musicPlayers[_activePlayer]
	if not player.playing or player.stream_paused or player.stream == null:
		return

	var position := player.get_playback_position() + AudioServer.get_time_since_last_mix()
	var remaining := player.stream.get_length() - position
	if remaining <= minf(TRACK_CROSSFADE_TIME, player.stream.get_length() * 0.5):
		_advance()


func _advance() -> void:
	_advancing = true # Reset by _crossfadeTo(), prevents that the next track is started twice

	var type := _currentType
	var path := _pickTrack(type)
	var stream := _loadTrack(path)
	if stream == null:
		return # Nothing to play, the current track just ends

	_crossfadeTo(type, path, stream, 0.0, TRACK_CROSSFADE_TIME)


# Fades a player out and stops it. Remembers where the track was, so it can be resumed.
func _retire(player : AudioStreamPlayer, type : Audio.MusicType, fade : float) -> void:
	if not _alive(player):
		return

	if type != Audio.MusicType.none and not _currentPath.is_empty() and not player.stream_paused:
		_resume[type] = { "path": _currentPath, "position": player.get_playback_position() }

	if player.stream_paused or fade <= 0.0:
		_killTween(player)
		player.stop()
		player.stream_paused = false
		return

	_fadeTo(player, SILENT_DB, fade, player.stop)


# A paused player reports playing = false, so "paused" has to count as alive
func _alive(player : AudioStreamPlayer) -> bool:
	return player.playing or player.stream_paused


func _unpause(player : AudioStreamPlayer) -> void:
	player.stream_paused = false
	_fadeTo(player, MUSIC_VOLUME_DB, PAUSE_FADE_TIME)


# Equal power fade: two tracks that fade at the same time keep the same loudness the whole time
func _fadeTo(player : AudioStreamPlayer, volumeDb : float, time : float, done : Callable = Callable()) -> void:
	_killTween(player)

	var fromAmp := db_to_linear(player.volume_db) if player.volume_db > SILENT_DB else 0.0
	var toAmp := db_to_linear(volumeDb) if volumeDb > SILENT_DB else 0.0

	var tween := create_tween()
	tween.tween_method(_applyFade.bind(player, fromAmp, toAmp), 0.0, 1.0, maxf(time, 0.001))
	if done.is_valid():
		tween.tween_callback(done)

	_tweens[player] = tween


func _applyFade(t : float, player : AudioStreamPlayer, fromAmp : float, toAmp : float) -> void:
	var shape := sin(t * PI * 0.5) if toAmp > fromAmp else 1.0 - cos(t * PI * 0.5)
	var amplitude := lerpf(fromAmp, toAmp, shape)
	player.volume_db = linear_to_db(amplitude) if amplitude > 0.0001 else SILENT_DB


func _killTween(player : AudioStreamPlayer) -> void:
	var tween := _tweens.get(player) as Tween
	if tween != null:
		tween.kill()
	_tweens.erase(player)


func _disableLoop(stream : AudioStream) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = false
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = false
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED


# Safety net: if a track ended before the crossfade could start (very short track, lag spike), continue right away
func _onMusicFinished(player : AudioStreamPlayer) -> void:
	if player == _musicPlayers[_activePlayer] and _currentType != Audio.MusicType.none and not _advancing and not player.stream_paused:
		_advance()

#endregion


#region Private functions: volumes

func _applyVolumesOnce() -> void:
	if not _volumesApplied:
		applyVolumes() # Does nothing as long as the settings are not loaded yet


func _setBusVolume(bus : StringName, linear : float) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index < 0:
		push_warning("AudioManager: Audio bus '%s' does not exist!" % bus)
		return

	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))
	if bus != MASTER_BUS:
		AudioServer.set_bus_mute(index, linear < 0.001)


func _refreshMasterMute() -> void:
	var index := AudioServer.get_bus_index(MASTER_BUS)
	if index < 0:
		return

	var mute := _masterSilent
	var settings := Globals.settingsManager
	if _focusLost and settings != null and settings.getBool("audio", "mute on focus loss"):
		mute = true

	AudioServer.set_bus_mute(index, mute)

#endregion
