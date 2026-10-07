extends Node
class_name Visuals


#region Exported variables

@export var camera : Camera3D = null
@export var environment : WorldEnvironment = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(camera != null, "Visuals._ready(): Camera not assigned!")
	assert(environment != null, "Visuals._ready(): World environment not assigned!")

	if Globals.visuals != null:
		push_error("Visuals._ready(): Visual components manager has already been initialized once!")

		return

	Globals.visuals = self

#endregion
