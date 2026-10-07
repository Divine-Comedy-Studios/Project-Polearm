extends SoliderAction


#region Constants

const MIN_PERIOD_MULTIPLIER : float = 0.7

#endregion


#region Exported variables

@export_group("Movement settings")
@export var WALK_SPEED : float = 2.0
@export var RUN_SPEED : float = 5.5
@export var ACCELERATION : float = 25.0

@export_group("Animation settings")
@export var IDLE_DATA : EntityActionData = null
@export var WALK_DATA : EntityActionData = null
@export var RUN_DATA : EntityActionData = null
@export var BLEND_LERP : float = 0.2

#endregion


#region Member variables

# Animation data

var _walkPeriod : float = 0.0
var _runPeriod : float = 0.0

var _blendScale : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	assert(IDLE_DATA != null, "SoliderAction Move._implInit(): Idle action data not assigned")
	assert(WALK_DATA != null, "SoliderAction Move._implInit(): Walking action data not assigned")
	assert(RUN_DATA != null, "SoliderAction Move._implInit(): Running action data not assigned")

	animator().animationDriver(&"Idle").animation = IDLE_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(&"Walk").animation = WALK_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(&"Run").animation = RUN_DATA.ANIMATION_FULL_NAME

	_walkPeriod = animator().animation(WALK_DATA.ANIMATION_FULL_NAME).length
	_runPeriod = animator().animation(RUN_DATA.ANIMATION_FULL_NAME).length

	data = WALK_DATA


func _implEnter() -> void:
	animator().setCoreTransition(&"AdvancedTransition", data.ANIMATION_FADE_TIME)
	animator().transitionTo(&"AdvancedTransition", &"Move")


func _implTick(delta : float) -> void:
	var targetSpeed : float = intents().magnitude * intents().speedMultiplier * RUN_SPEED
	entity().accelerateFlat(intents().direction * targetSpeed, ACCELERATION * delta)

	_processAnimations()

#endregion


#region Private functions

func _processAnimations() -> void:
	_blendScale = lerpf(_blendScale, maxf(
		clampf(PPUtil.Math.toRangeNormalized(entity().velocity.length(), WALK_SPEED, RUN_SPEED), -1.0, 1.0),
		-MIN_PERIOD_MULTIPLIER
	), BLEND_LERP)
	var period := maxf(
		_walkPeriod + _blendScale * (_runPeriod - _walkPeriod),
		_walkPeriod * MIN_PERIOD_MULTIPLIER
	)

	frameDataScale = _walkPeriod / period
	animator().setScale(&"WalkScale", frameDataScale)
	animator().setScale(&"RunScale", _runPeriod / period)
	animator().setBlendAmount(&"Move", _blendScale)

#endregion
