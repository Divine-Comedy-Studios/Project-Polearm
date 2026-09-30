@tool

extends Area3D
class_name EventTrigger



#region Exported variables

@export_flags_3d_physics var layers : int:
	get:
		return collision_mask
	set(value):
		collision_mask = value

#endregion


#region Member variables

# Scene members

var _collisionShape : CollisionShape3D = null

# Properties

var shape : Shape3D:
	get:
		return _collisionShape.shape
	set(value):
		_collisionShape.shape = value

#endregion


#region Built-in functions

func _init() -> void:
	_collisionShape = CollisionShape3D.new()
	add_child(_collisionShape)


func _ready() -> void:
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
