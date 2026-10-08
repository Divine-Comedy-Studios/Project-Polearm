@tool

extends Projectile
class_name HomingMissile


#region Member variables

var _speed : float = 0.0

var _target : Node3D = null
var _offset : Vector3 = Vector3.ZERO

#endregion


#region Exported variables

@export var TURN_SPEED : float = 8.0

#endregion


#region Built-in functions

func _spawn(physics : ProjectilePhysics) -> void:
	_speed = physics.FLAT_SPEED
	_velocity = physics.normDirection * _speed

	_target = physics.target
	_offset = physics.OFFSET


func _tick(delta : float) -> void:
	if Engine.is_editor_hint():
		return

	if is_instance_valid(_target):
		_velocity = _velocity.lerp(
			global_position.direction_to(_target.global_position + _offset) * _speed,
			TURN_SPEED * delta
		)

	_velocity = _velocity.normalized() * _speed

#endregion
