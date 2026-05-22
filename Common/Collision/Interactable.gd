@tool

extends Area3D
class_name Interactable


#region Exported variables

@export_flags_3d_physics var LAYERS : int:
	get:
		return collision_layer
	set(value):
		collision_layer = value

#endregion


#region Built-in functions

func _ready() -> void:
	if Engine.is_editor_hint():
		collision_mask = 0

		monitoring = true
		monitorable = false

#endregion


#region Public functions

func enable() -> void:
	monitorable = true

func disable() -> void:
	monitorable = false

#endregion


#region Virtual functions

@warning_ignore("unused_parameter")
func interact(payload : Variant) -> void:
	pass

#endregion
