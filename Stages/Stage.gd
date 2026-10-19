extends Node
class_name Stage


#region Enums

enum Type {
	NULL = 0,

	GYM = 1,
	LEVEL_1 = 2,
}

#endregion


#region Exported variables

@export var DATA : StageData = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(DATA != null, "Stage._ready(): Stage data not assigned!")

#endregion
