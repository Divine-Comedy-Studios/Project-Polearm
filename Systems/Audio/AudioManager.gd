extends Node
class_name AudioManager

# Lives in Main, so it survives every scene change.
#	Music:	Globals.audioManager.playMusic(MusicData.Type.game)
#	UI:		Globals.audioManager.playSfx2D(SFXData.Type.uiClick)
# Sounds in the world (3D, directional) go through the SFXManager inside the World.


#region Constants

const MASTER_BUS := &"Master"
const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"

const SILENT_DB := -80.0
const UI_POOL_SIZE := 8

#endregion


#region Exported variables

@export_group("Music config")
@export var MUSIC_DATASET : MusicDataset = null
## Time in seconds to fade a track out, and the next one in
@export var FADE_TIME : float = 0.5

@export_group("SFX config")
@export var SFX_DATASET : SFXDataset = null

#endregion


#region Member variables

var muteOnFocusLost : bool = false

# Music
var _musicPlayer : AudioStreamPlayer = null
var _musicTween : Tween = null
var _currentType : MusicData.Type = MusicData.Type.none

# UI sounds
var _uiPlayers : Array[AudioStreamPlayer] = []
var _uiNext : int = 0
var _lastPlayed : Dictionary[SFXData.Type, int] = {} # msec

#endregion


#region Built-in functions

func _ready() -> void:
	assert(MUSIC_DATASET != null, "AudioManager._ready(): Music dataset not assigned!")
	assert(SFX_DATASET != null, "AudioManager._ready(): SFX dataset not assigned!")

	if Globals.audioManager != null:
		push_error("AudioManager._ready(): AudioManager has already been initialized once!")
		return

	Globals.audioManager = self
	process_mode = Node.PROCESS_MODE_ALWAYS # Audio keeps going while the world is paused

	_musicPlayer = AudioStreamPlayer.new()
	_musicPlayer.bus = MUSIC_BUS
	add_child(_musicPlayer)

	for i in UI_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_uiPlayers.push_back(player)


func _notification(what : int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			setMasterMute(true)
		NOTIFICATION_APPLICATION_FOCUS_IN:
			setMasterMute(false)

#endregion


#region Public functions

# Fades the current track out and the track of the new type in. Does nothing if the type is already playing.
func playMusic(type : MusicData.Type) -> void:
	if type == _currentType:
		return

	_currentType = type

	if _musicTween != null:
		_musicTween.kill()

	if _musicPlayer.playing:
		_musicTween = create_tween()
		_musicTween.tween_property(_musicPlayer, "volume_db", SILENT_DB, FADE_TIME)
		_musicTween.tween_callback(_startMusic)
	else:
		_startMusic()


func stopMusic() -> void:
	playMusic(MusicData.Type.none)


# Non-positional sound, e.g. for menus. Sounds in the world use the SFXManager.
func playSfx2D(type : SFXData.Type) -> void:
	var data := SFX_DATASET.DATASET.get(type) as SFXData
	if data == null or data.STREAMS.is_empty():
		push_warning("AudioManager.playSfx2D(): No sound registered for '%s'." % SFXData.Type.keys()[type])
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


func setBusVolume(bus : StringName, linear : float) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index < 0:
		push_warning("AudioManager._setBusVolume(): Audio bus '%s' does not exist!" % bus)
		return

	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))

func setMasterMute(mute : bool) -> void:
	var index := AudioServer.get_bus_index(MASTER_BUS)
	AudioServer.set_bus_mute(index, mute and muteOnFocusLost)

#endregion


#region Private functions

# Starts the track of the current type from the beginning and fades it in
func _startMusic() -> void:
	_musicPlayer.stop()

	if _currentType == MusicData.Type.none:
		return

	var data : Variant = MUSIC_DATASET.DATASET.get(_currentType)
	if data == null:
		push_error("AudioManager._startMusic(): Missing music entry in datasheet!")
		return
	
	var stream = (data as MusicData).pick()
	if stream == null:
		push_error("AudioManager._startMusic(): Music entry in datasheet does not contain valid music!")
		return

	_musicPlayer.stream = stream
	_musicPlayer.volume_db = SILENT_DB
	_musicPlayer.play()

	_musicTween = create_tween()
	_musicTween.tween_property(_musicPlayer, "volume_db", data.VOLUME_DB, FADE_TIME)

#endregion
