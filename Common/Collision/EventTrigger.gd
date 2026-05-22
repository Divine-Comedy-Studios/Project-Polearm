@tool

extends Area3D
class_name EventTrigger


#region Exported variables

@export_flags_3d_physics var LAYERS : int:
	get:
		return collision_mask
	set(value):
		collision_mask = value

#endregion


#region Built-in functions

func _ready() -> void:
	if Engine.is_editor_hint():
		collision_layer = 0

		monitoring = false # true if a hitbox should be enabled on start
		monitorable = false

	body_entered.connect(trigger)

#endregion


#region Public functions

func enable() -> void:
	monitoring = true

func disable() -> void:
	monitoring = false


# Can also be triggered manually
@warning_ignore("unused_parameter")
func trigger(node : Node3D) -> void:
	pass

#endregion
