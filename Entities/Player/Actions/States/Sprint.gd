extends PlayerAction


#region Exported variables

@export_group("Animation settings")
@export var SPRINT_DATA : PlayerActionData = null
@export var TURN_LEFT_DATA : PlayerActionData = null
@export var TURN_RIGHT_DATA : PlayerActionData = null

@export_group("Movement settings")
@export var TURN_COS_THRESHHOLD : float = 0.5

@export_group("Footstep settings")
@export var FOOTSTEP_TIME : float = 0.25

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


# Footsteps
var _footstepTimer : float = 0.0

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


func _implTick(delta : float) -> void:
	# Switch to special turning state
	_checkTurning()

	player().accelerateFlat3(_direction * _speed, _accel * delta)

	if inputs().modifiers.has(Type.sprint):
		context().pushActionQueue(Type.sprint)
	else:
		context().pushActionQueue(Type.sprintStop)
	
	if not _turning:
		_processFootsteps(delta)

func _processDirection(delta : float) -> void:
	if _turning:
		var rotationTrackingSpeed := _turnTargetAngle / _turnDuration * delta
		_context.entity.rotate_y(rotationTrackingSpeed)
	else:
		super._processDirection(delta)

#endregion


#region Private functions

func _checkTurning() -> void:
	var zeroInputMag := is_zero_approx(inputs().inputMagnitude)

	# First, check if the player was turning and if the animation is done
	if _turning:
		if finished():
			exit()
			enter()

		return # If the player is turning, the target direction shouldn't be changed

	_direction = player().forward()
	_direction.y = 0.0
	_direction = _direction.normalized()

	if zeroInputMag:
		return

	# Check if the player has turned

	var direction = PPUtil.Math.flatToVec3(inputs().direction)
	if direction.dot(_direction) < TURN_COS_THRESHHOLD:
		_turnTargetAngle = _direction.signed_angle_to(direction, Vector3.UP)

		exit()

		_turning = true
		_direction = direction

		if _turnTargetAngle > 0:
			_targetAnimation = TURN_LEFT_DATA
		else:
			_targetAnimation = TURN_RIGHT_DATA

		enter()


func _processFootsteps(delta : float) -> void:
	_footstepTimer -= delta
	if _footstepTimer > 0.0:
		return

	_footstepTimer = FOOTSTEP_TIME

	Globals.sfxManager.play(SFXData.Type.footstep, player().global_position)

#endregion
