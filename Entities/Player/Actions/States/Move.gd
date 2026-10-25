extends PlayerAction


#region Constants

const MIN_PERIOD_MULTIPLIER : float = 0.7

#endregion


#region Exported variables

@export_group("Input settings")
@export var TURN_INPUT_MIN : float = 0.1

@export_group("Animation settings")
@export var IDLE_DATA : PlayerActionData = null
@export var WALK_DATA : PlayerActionData = null
@export var RUN_DATA : PlayerActionData = null
@export var BLEND_LERP : float = 0.2

@export_group("Footstep settings")
@export var WALK_FOOTSTEP_TIME : float = 0.6
@export var RUN_FOOTSTEP_TIME : float = 0.35

#endregion


#region Member variables

# Movement settings

var _walkSpeed : float = 0.0
var _runSpeed : float = 0.0
var _accel : float = 0.0


# Animation data

var _walkPeriod : float = 0.0
var _runPeriod : float = 0.0

var _maxPeriod : float = 0.0

var _blendScale : float = 0.0


# Turning state
var _targetDirection : Vector3


# Footsteps
var _footstepTimer : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	assert(IDLE_DATA != null, "PlayerActionMove._implInit(): Idle action data not assigned")
	assert(WALK_DATA != null, "PlayerActionMove._implInit(): Walking action data not assigned")
	assert(RUN_DATA != null, "PlayerActionMove._implInit(): Running action data not assigned")


	_walkSpeed = physics().WALK_SPEED
	_runSpeed = physics().RUN_SPEED
	_accel = physics().GROUNDED_ACCELERATION


	animator().animationDriver(&"Idle").animation = IDLE_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(&"Walk").animation = WALK_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(&"Run").animation = RUN_DATA.ANIMATION_FULL_NAME

	_walkPeriod = animator().animation(WALK_DATA.ANIMATION_FULL_NAME).length
	_runPeriod = animator().animation(RUN_DATA.ANIMATION_FULL_NAME).length

	_maxPeriod = _walkPeriod + 0.5 * (_runPeriod - _walkPeriod)

	data = WALK_DATA


func _implEnter() -> void:
	_targetDirection = player().forward()
	_footstepTimer = 0.0

	animator().setCoreTransition(&"AdvancedTransition", data.ANIMATION_FADE_TIME)
	animator().transitionTo(&"AdvancedTransition", &"Move")


func _implTick(delta : float) -> void:
	var targetSpeed := minf(inputs().inputMagnitude * _runSpeed, _runSpeed)
	player().accelerateFlat(inputs().direction * targetSpeed, _accel * delta)

	if inputs().inputMagnitude > TURN_INPUT_MIN:
		_targetDirection = PPUtil.Math.flatToVec3(inputs().direction)


	_processAnimations()

	_processFootsteps(delta)


func _processDirectionAngle() -> float:
	return player().forward().signed_angle_to(
		_targetDirection, 
		Vector3.UP
	)


func _implNextAction(next : StringName) -> StringName:
	if next == Type.none:
		return Type.none

	if not hasHigherPriorityThan(next):
		return next

	if not is_zero_approx(_processDirectionAngle()):
		return Type.none

	return Type.moveStop

#endregion


#region Private functions

func _processAnimations() -> void:
	_blendScale = lerpf(_blendScale, maxf(
		clampf(PPUtil.Math.toRangeNormalized(player().velocity.length(), _walkSpeed, _runSpeed), -1.0, 1.0), 
		-MIN_PERIOD_MULTIPLIER
	), BLEND_LERP)
	var period = maxf(
		_walkPeriod + _blendScale * (_runPeriod - _walkPeriod),
		_walkPeriod * MIN_PERIOD_MULTIPLIER
	)

	frameDataScale = _walkPeriod / period
	animator().setScale(&"WalkScale", frameDataScale)
	animator().setScale(&"RunScale", _runPeriod / period)
	animator().setBlendAmount(&"Move", _blendScale)


func _processFootsteps(delta : float) -> void:
	_footstepTimer -= delta
	if _footstepTimer > 0.0:
		return

	var runAmount := clampf(inverse_lerp(_walkSpeed, _runSpeed, player().velocity.length()), 0.0, 1.0)
	_footstepTimer = lerpf(WALK_FOOTSTEP_TIME, RUN_FOOTSTEP_TIME, runAmount)

	Globals.sfxManager.play(SFXData.Type.footstep, player().global_position)

#endregion
