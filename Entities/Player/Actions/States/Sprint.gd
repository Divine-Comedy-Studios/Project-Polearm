extends PlayerAction


#region Exported variables

@export_group("Animation settings")
@export var SPRINT_DATA : PlayerActionData = null
@export var TURN_LEFT_DATA : PlayerActionData = null
@export var TURN_RIGHT_DATA : PlayerActionData = null

#endregion


#region Member variables

# Sprinting behavior

var _speed : float = 0.0
var _accel : float = 0.0

var _direction : Vector3 = Vector3.ZERO

# Turing beavior

var _turning := false # Technically anti-ideomatic, as it should belong in another state, but that state would share 90% of its behavior with sprinting
var _turnDuration : float = 0.0

var _turnTargetAngle : float = 0.0

var _targetAnimation : PlayerActionData = null

#endregion


#region Override functions

func _viable() -> bool:
	return player().onGround()


func _implInit() -> void:
	assert(TURN_LEFT_DATA != null, "PlayerActionMoveTurn._implInit(): Turn left action data not assigned")
	assert(TURN_RIGHT_DATA != null, "PlayerActionMoveTurn._implInit(): Turn right action data not assigned")
	assert(SPRINT_DATA != null, "PlayerActionMoveTurn._implInit(): Sprint data not assigned")

	_targetAnimation = SPRINT_DATA

	_turnDuration = animator().animation(TURN_LEFT_DATA.ANIMATION_FULL_NAME).length

	_speed = physics().SPRINT_SPEED
	_accel = physics().GROUNDED_ACCELERATION


func _implEnter() -> void:
	data = _targetAnimation

	_animationSetupBasic()


func _implExit() -> void:
	_targetAnimation = SPRINT_DATA
	_direction = Vector3.ZERO
	_turning = false


func _tick(delta : float) -> void:
	# Switch to special turning state
	_checkTurning()

	var dir := inputs().direction
	if dir.is_zero_approx():
		_direction = player().forward()
	else:
		_direction.x = dir.x
		_direction.z = dir.y

	player().accelerateFlat3(_direction * _speed, _accel * delta)

	if inputs().modifiers.has(Type.sprint):
		context().pushActionQueue(Type.sprint)
	else:
		context().pushActionQueue(Type.sprintStop)


func _processDirection(delta : float) -> void:
	if _turning:
		var rotationTrackingSpeed := _turnTargetAngle / _turnDuration * delta
		if rotationTrackingSpeed != 0.0:
			_context.entity.rotate_y(rotationTrackingSpeed)
	else:
		super._processDirection(delta)

#endregion


#region Private functions

func _checkTurning() -> void:
	var forward3 : Vector3 = player().forward()
	var forward = Vector2(forward3.x, forward3.z).normalized()
	if not _turning and not is_zero_approx(inputs().inputMagnitude) and inputs().direction.dot(forward) < 0.8:
		exit()

		_turning = true
		_turnTargetAngle = inputs().direction.angle_to(forward)

		if _turnTargetAngle > 0:
			_targetAnimation = TURN_LEFT_DATA
		else:
			_targetAnimation = TURN_RIGHT_DATA

		enter()

	if _turning and finished():
		exit()
		enter()

#endregion
