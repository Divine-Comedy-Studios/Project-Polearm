extends PlayerAction


#region Constants

const MIN_PERIOD_MULTIPLIER := 0.7

#endregion


#region Exported variables

@export_group("Animation settings")
@export var IDLE_DATA : PlayerActionData = null
@export var WALK_DATA : PlayerActionData = null
@export var RUN_DATA : PlayerActionData = null
@export var BLEND_LERP : float = 0.3

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
	# Switch to special turning state
	#var forward : Vector3 = player().forward()
	#if inputs().direction.dot(Vector2(forward.x, forward.z).normalized()) < 0.8:
	#	context().interrupt(Type.moveTurn)
	#	return

	animator().setCoreTransition(&"AdvancedTransition", data.ANIMATION_FADE_TIME)
	animator().transitionTo(&"AdvancedTransition", &"Move")


func _tick(delta : float) -> void:
	# Movement
	var targetSpeed := minf(inputs().inputMagnitude * _runSpeed, _runSpeed)
	player().accelerateFlat(inputs().direction * targetSpeed, _accel * delta)

	# Animation
	_processAnimations()


func _implNextAction(next : StringName) -> StringName:
	if next != Type.none and hasHigherPriorityThan(next):
		return Type.moveStop

	return next

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

#endregion
