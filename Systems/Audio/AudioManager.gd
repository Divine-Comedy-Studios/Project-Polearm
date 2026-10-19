extends Node
class_name AudioManager

# Lives in Main, so it survives every scene change.
#	Music:	Globals.audioManager.playMusic(Audio.MusicType.game)
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

#endregion


#region Exported variables

@export_group("Music")
@export var MUSIC_DATASET : MusicDataset = null
@export var CROSSFADE_TIME : float = 1.0
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
var _currentData : MusicData = null
var _positions : Dictionary = {} # MusicType -> last playback position, used to resume a track
var _tweens : Dictionary = {}    # AudioStreamPlayer -> running fade

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
	assert(MUSIC_DATASET != null, "AudioManager._ready(): Music dataset not assigned!")

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

# resume = continue the track where it was left the last time instead of starting from the beginning
func playMusic(type : Audio.MusicType, resume : bool = false) -> void:
	_applyVolumesOnce()

	_inPause = false
	_pausedType = Audio.MusicType.none

	if type == Audio.MusicType.none:
		stopMusic()
		return

	var data := _musicData(type)
	if data == null:
		push_warning("AudioManager.playMusic(): No music with a stream registered for '%s'." % Audio.MusicType.keys()[type])
		return

	var current := _musicPlayers[_activePlayer]
	if type == _currentType and _alive(current):
		if current.stream_paused: # Same track was paused: just continue it
			_unpause(current, data)
		return

	_crossfadeTo(type, data, resume)


func stopMusic(fadeTime : float = -1.0) -> void:
	_inPause = false
	_pausedType = Audio.MusicType.none

	_retire(_musicPlayers[_activePlayer], _currentType, CROSSFADE_TIME if fadeTime < 0.0 else fadeTime)
	_currentType = Audio.MusicType.none
	_currentData = null


# Call when the game gets paused / unpaused. What happens depends on PAUSE_BEHAVIOR.
func enterPause() -> void:
	if _inPause:
		return

	_inPause = true
	_pausedType = _currentType

	if PAUSE_BEHAVIOR == PauseBehavior.track:
		var pauseData := _musicData(Audio.MusicType.pause)
		if pauseData != null:
			_crossfadeTo(Audio.MusicType.pause, pauseData, false)
			return

	# Silence (also the fallback when there is no pause track)
	var current := _musicPlayers[_activePlayer]
	if current.playing and not current.stream_paused:
		_positions[_currentType] = current.get_playback_position()
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
	if _alive(current) and _currentData != null:
		_unpause(current, _currentData)


func currentMusic() -> Audio.MusicType:
	return _currentType

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

func _musicData(type : Audio.MusicType) -> MusicData:
	var data := MUSIC_DATASET.DATASET.get(type) as MusicData
	if data == null or data.STREAM == null:
		return null

	return data


func _crossfadeTo(type : Audio.MusicType, data : MusicData, resume : bool) -> void:
	var fade := data.FADE_TIME if data.FADE_TIME >= 0.0 else CROSSFADE_TIME

	var oldPlayer := _musicPlayers[_activePlayer]
	var oldType := _currentType

	_activePlayer = 1 - _activePlayer
	var newPlayer := _musicPlayers[_activePlayer]

	_retire(oldPlayer, oldType, fade)
	_enableLoop(data)

	_killTween(newPlayer)
	newPlayer.stream = data.STREAM
	newPlayer.stream_paused = false
	newPlayer.volume_db = SILENT_DB if fade > 0.0 else data.VOLUME_DB

	var start := 0.0
	if resume:
		start = _positions.get(type, 0.0)
		if start >= data.STREAM.get_length():
			start = 0.0
	newPlayer.play(start)

	if fade > 0.0:
		_fadeTo(newPlayer, data.VOLUME_DB, fade)

	_currentType = type
	_currentData = data


# Fades a player out and stops it. Remembers where the track was, so it can be resumed.
func _retire(player : AudioStreamPlayer, type : Audio.MusicType, fade : float) -> void:
	if not _alive(player):
		return

	if type != Audio.MusicType.none and not player.stream_paused:
		_positions[type] = player.get_playback_position()

	if player.stream_paused or fade <= 0.0:
		_killTween(player)
		player.stop()
		player.stream_paused = false
		return

	_fadeTo(player, SILENT_DB, fade, player.stop)


# A paused player reports playing = false, so "paused" has to count as alive
func _alive(player : AudioStreamPlayer) -> bool:
	return player.playing or player.stream_paused


func _unpause(player : AudioStreamPlayer, data : MusicData) -> void:
	player.stream_paused = false
	_fadeTo(player, data.VOLUME_DB, PAUSE_FADE_TIME)


func _fadeTo(player : AudioStreamPlayer, volumeDb : float, time : float, done : Callable = Callable()) -> void:
	_killTween(player)

	var tween := create_tween()
	tween.tween_property(player, "volume_db", volumeDb, maxf(time, 0.001)).set_trans(Tween.TRANS_SINE)
	if done.is_valid():
		tween.tween_callback(done)

	_tweens[player] = tween


func _killTween(player : AudioStreamPlayer) -> void:
	var tween := _tweens.get(player) as Tween
	if tween != null:
		tween.kill()
	_tweens.erase(player)


# Makes the stream loop (ogg, mp3 and wav). If the import settings already loop it, nothing changes.
func _enableLoop(data : MusicData) -> void:
	if not data.LOOP:
		return

	var stream := data.STREAM
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		if wav.loop_mode == AudioStreamWAV.LOOP_DISABLED:
			wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
			wav.loop_begin = 0
			wav.loop_end = int(wav.get_length() * wav.mix_rate)


# Fallback for streams that could not be set to loop: start them again (a tiny gap is possible)
func _onMusicFinished(player : AudioStreamPlayer) -> void:
	if player == _musicPlayers[_activePlayer] and _currentData != null and _currentData.LOOP:
		player.play()

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
