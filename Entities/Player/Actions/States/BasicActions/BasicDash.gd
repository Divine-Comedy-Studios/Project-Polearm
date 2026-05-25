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
	_direction = Vector3(inputs().direction.x, 0, inputs().direction.y)
	if _direction.is_zero_approx():
		_direction = player().forward()
	else:
		player().setMovementFlat(
			Vector2(player().movement().x, player().movement().z).length() * inputs().direction * physics().DIRECTIONAL_SNAP_FACTOR)

	_animationSetupBasic()

func _tick(delta : float) -> void:
	player().accelerateFlat3(_direction * _speed, _accel * delta)

#endregion
