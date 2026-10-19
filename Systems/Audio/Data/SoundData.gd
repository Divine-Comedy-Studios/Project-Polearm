extends Resource
class_name SoundData


## Several streams = variations. One is picked at random each time (never the same twice in a row).
@export var STREAMS : Array[AudioStream] = []
@export_range(-40.0, 12.0) var VOLUME_DB : float = 0.0
@export_range(0.5, 2.0) var PITCH_MIN : float = 0.95
@export_range(0.5, 2.0) var PITCH_MAX : float = 1.05

@export_group("3D")
## Beyond this distance the sound is silent
@export var MAX_DISTANCE : float = 40.0
## How fast the sound fades with distance. Larger = carries further.
@export var UNIT_SIZE : float = 8.0

@export_group("Limits")
## Minimum time in seconds between two plays of this sound (0 = no limit)
@export var COOLDOWN : float = 0.0
## How many copies of this sound may play at the same time. Extra ones are dropped.
@export var MAX_INSTANCES : int = 4


var _last : int = -1


func pick() -> AudioStream:
	if STREAMS.is_empty():
		return null

	if STREAMS.size() == 1:
		return STREAMS[0]

	var index := randi() % STREAMS.size()
	if index == _last:
		index = (index + 1) % STREAMS.size()

	_last = index
	return STREAMS[index]


func randomPitch() -> float:
	return randf_range(minf(PITCH_MIN, PITCH_MAX), maxf(PITCH_MIN, PITCH_MAX))
