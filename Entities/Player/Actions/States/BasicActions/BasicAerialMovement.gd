extends PlayerAction
class_name BasicAerialMovement


#region Member variables

# Movement settings

var _maxSpeed : float = 0.0
var _maxSpeedSq : float = 0.0
var _accel : float = 0.0
var _friction : float = 0.0
var _entrySpeed : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_maxSpeed = physics().MAX_AERIAL_SPEED
	_maxSpeedSq = _maxSpeed * _maxSpeed
	_accel = physics().AERIAL_ACCELERATION
	_friction = physics().AERIAL_FRICTION
	_entrySpeed = physics().SPRINT_SPEED

#endregion


#region Public functions

func moveAerial(delta : float) -> void:
	var targetSpeed := minf(inputs().inputMagnitude * _maxSpeed, _maxSpeed)

	if not is_zero_approx(targetSpeed) and player().movement().length_squared() < _maxSpeedSq:
		player().accelerateFlat(inputs().direction * targetSpeed, _accel * delta)
	else:
		player().accelerateFlat(Vector3.ZERO, _friction * delta)

#endregion
