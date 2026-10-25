extends Node
class_name SFXManager

# Plays sounds at a position in the world. Goes into World.tscn (one node, like the other managers).
#	Globals.sfxManager.play(SFXData.Type.hit, hitPosition)
# Sounds are pooled, directional (AudioStreamPlayer3D) and freeze together with the world: Godot pauses
# 3D players by itself when their parent is disabled (as the World is while the game is paused).


#region Constants

const SFX_BUS := &"SFX"

#endregion


#region Exported variables

@export_group("SFX config")
@export var POOL_SIZE : int = 24

#endregion


#region Member variables

var SFX_DATASET : SFXDataset = null

var _free : Array[AudioStreamPlayer3D] = []
var _active : Array[AudioStreamPlayer3D] = [] # Oldest first
var _typeOf : Dictionary = {}      # AudioStreamPlayer3D -> SfxType
var _typeCount : Dictionary = {}   # SfxType -> number of copies currently playing
var _lastPlayed : Dictionary = {}  # SfxType -> msec

var _listener : AudioListener3D = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(Globals.audioManager != null, "SFXManager._ready(): SFXManager requires global audio manager!")

	if Globals.sfxManager != null:
		push_error("SFXManager._ready(): SFXManager has already been initialized once!")

		return

	SFX_DATASET = Globals.audioManager.SFX_DATASET

	Globals.sfxManager = self

	for i in POOL_SIZE:
		var player := AudioStreamPlayer3D.new()
		player.bus = SFX_BUS
		player.finished.connect(_onFinished.bind(player))
		add_child(player)
		_free.push_back(player)

#endregion


#region Public functions

# volumeScale 0..1 makes a single play quieter, e.g. weak hits
func play(type : SFXData.Type, position : Vector3, volumeScale : float = 1.0) -> void:
	if type == SFXData.Type.none:
		return

	var data := SFX_DATASET.DATASET.get(type) as SFXData
	if data == null:
		push_error("SFXManager.play(): Missing SFX entry in dataset!")

		return

	var now := Time.get_ticks_msec()
	if data.COOLDOWN > 0.0 and now - _lastPlayed.get(type, -1000000) < data.COOLDOWN * 1000.0:
		return

	if _typeCount.get(type, 0) >= data.MAX_INSTANCES:
		return

	_lastPlayed[type] = now

	var player := _acquire()
	_typeOf[player] = type
	_typeCount[type] = _typeCount.get(type, 0) + 1
	_active.push_back(player)

	player.global_position = position
	player.stream = data.pick()
	player.volume_db = data.VOLUME_DB + linear_to_db(clampf(volumeScale, 0.0001, 1.0))
	player.pitch_scale = data.randomPitch()
	player.max_distance = data.MAX_DISTANCE
	player.unit_size = data.UNIT_SIZE
	player.play()


# The 3D sounds are heard from the active camera. With a camera far above the player that is not what
# you want: call this once with the player (or its model) so distances and left/right are measured from it.
func attachListener(target : Node3D) -> void:
	if _listener == null:
		_listener = AudioListener3D.new()

	if _listener.get_parent() != null:
		_listener.get_parent().remove_child(_listener)

	target.add_child(_listener)
	_listener.make_current()


# Stops everything immediately, e.g. when a stage is reset
func clear() -> void:
	for player in _active.duplicate():
		player.stop()
		_release(player)

#endregion


#region Private functions

func _acquire() -> AudioStreamPlayer3D:
	if not _free.is_empty():
		return _free.pop_back()

	var oldest := _active.pop_front() as AudioStreamPlayer3D
	oldest.stop()
	_countDown(oldest)
	return oldest


func _release(player : AudioStreamPlayer3D) -> void:
	_active.erase(player)
	_countDown(player)
	_free.push_back(player)


func _countDown(player : AudioStreamPlayer3D) -> void:
	var type : SFXData.Type = _typeOf.get(player, SFXData.Type.none)
	_typeCount[type] = maxi(_typeCount.get(type, 1) - 1, 0)
	_typeOf.erase(player)

#endregion


#region Signal functions

func _onFinished(player : AudioStreamPlayer3D) -> void:
	_release(player)

#endregion
