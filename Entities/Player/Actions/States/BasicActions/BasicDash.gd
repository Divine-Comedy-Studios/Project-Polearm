extends PlayerAction
class_name PlayerBasicDash


#region Member variables

var _speed : float = 0.0
var _accel : float = 0.0

var _direction : Vector3 = Vector3.ZERO

#endregion


#region Override functions

func _implInit() -> void:
	_speed = physics().DASH_SPEED
	_accel = physics().DASH_ACCELERATION

func _implEnter() -> void:
	player().setMovementFlat(Vector2.ZERO) # Reset horizontal speed before dash, the player won't move faster than this anyways

	_direction = Vector3(inputs().direction.x, 0, inputs().direction.y)
	if _direction.is_zero_approx():
		_direction = player().forward()

	_animationSetupBasic()

func _tick(delta : float) -> void:
	player().accelerateFlat3(_direction * _speed, _accel * delta)

#endregion
