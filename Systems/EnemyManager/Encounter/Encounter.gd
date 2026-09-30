extends Resource
class_name Encounter


@export_group("Encounter region config")
@export var TRANSFORM : Transform3D = Transform3D.IDENTITY
@export var ENCOUNTER_REGION : Shape3D = null
@export var TRIGGER_REGION : Shape3D = null

@export_group("Encounter config")
@export var WAVES : Array[Wave]
# @export var REPEATABLE : bool = false ### @todo Will not be implemented
# @export var PRESPAWN_FIRST_WAVE : bool = false ### @todo Will not be implemented
@export var SCRIPT : String = String()
