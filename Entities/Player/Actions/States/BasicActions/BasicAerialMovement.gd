extends PlayerAction
class_name BasicAerialMovement


#region Exported variables

@export var MAX_ENTRY_SPEED : float = 10.0

#endregion


#region Member variables

var _maxSpeed : float = 0.0
var _accel : float = 0.0
var _friction : float = 0.0
var _entrySpeed : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_maxSpeed = physics().MAX_AERIAL_SPEED
	_accel = physics().AERIAL_ACCELERATION
	_friction = physics().AERIAL_FRICTION

#endregion


#region Public functions

func moveAerial(delta : float) -> void:
	var cap := maxf(_entrySpeed, _maxSpeed)
	var targetSpeed := minf(inputs().inputMagnitude * cap, cap)

	if is_zero_approx(targetSpeed):
		player().accelerateFlat(Vector3.ZERO, _friction * delta)
	else:
		player().accelerateFlat(inputs().direction * targetSpeed, _accel * delta)

#endregion
