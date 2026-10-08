extends Resource
class_name Encounter

@export_group("Encounter config")
@export var WAVES : Array[Wave]
# @export var REPEATABLE : bool = false ### @todo Will not be implemented
# @export var PRESPAWN_FIRST_WAVE : bool = false ### @todo Will not be implemented


@export_group("IGNORE")
@export var SPAWN_POINTS : Array[Vector3] = [ ]
