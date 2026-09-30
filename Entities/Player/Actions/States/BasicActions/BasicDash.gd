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
	var inputDir := inputs().direction

	if inputDir.is_zero_approx():
		_direction = player().forward()
	else:
		_direction = PPUtil.Math.flatToVec3(inputDir)

		var horizontalVel := PPUtil.Math.toFlatVec2(player().movement())
		if not horizontalVel.is_zero_approx():
			var velLen := horizontalVel.length()
			var directionVelocityDot := inputDir.dot(horizontalVel / velLen)

			player().setMovement(_direction * velLen * (physics().DIRECTIONAL_SNAP_FACTOR * (1.0 - directionVelocityDot) + directionVelocityDot))

	_animationSetupBasic()

func _implTick(delta : float) -> void:
	player().accelerateFlat3(_direction * _speed, _accel * delta)

#endregion
