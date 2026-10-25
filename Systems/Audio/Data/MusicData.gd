extends Resource
class_name MusicData


enum Type {
	none,
	mainMenu,
	game,
	pause,
}


@export var STREAMS : Array[AudioStream] = [ ]
@export_range(-40.0, 6.0) var VOLUME_DB : float = 0.0


func pick() -> AudioStream:
	if STREAMS.is_empty():
		return null

	return STREAMS[randi_range(0, STREAMS.size() - 1)]
