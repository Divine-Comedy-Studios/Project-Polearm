extends PlayerAction


#region Constants

const MIN_PERIOD_MULTIPLIER := 0.7

#endregion


#region Exported variables

@export_group("Movement settings")
@export var ACCELERATION : float = 25.0
@export var RUN_SPEED_MAX : float = 5.0
@export var WALK_SPEED_MAX : float = 2.0


@export_group("Animation settings")
@export var IDLE_DATA : PlayerActionData = null
@export var WALK_DATA : PlayerActionData = null
@export var RUN_DATA : PlayerActionData = null

#endregion


#region Member variables

# Animation data

var _walkPeriod : float = 0.0
var _runPeriod : float = 0.0

var _maxPeriod : float = 0.0

var _period : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	assert(IDLE_DATA != null, "PlayerActionMove._implInit(): Idle action data not assigned")
	assert(WALK_DATA != null, "PlayerActionMove._implInit(): Walking action data not assigned")
	assert(RUN_DATA != null, "PlayerActionMove._implInit(): Running action data not assigned")

	animator().animationDriver(&"Idle").animation = IDLE_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(&"Walk").animation = WALK_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(&"Run").animation = RUN_DATA.ANIMATION_FULL_NAME

	_walkPeriod = animator().animation(WALK_DATA.ANIMATION_FULL_NAME).length
	_runPeriod = animator().animation(RUN_DATA.ANIMATION_FULL_NAME).length

	_maxPeriod = _walkPeriod + 0.5 * (_runPeriod - _walkPeriod)

	data = WALK_DATA


func _implEnter() -> void:
	resources().jumpCount.value = 0

	animator().setCoreTransition(&"AdvancedTransition", data.ANIMATION_FADE_TIME)
	animator().transitionTo(&"AdvancedTransition", &"Move")


func _implExit() -> void:
	pass


func _tick(delta : float) -> void:
	# Movement
	var targetSpeed := minf(inputs().inputMagnitude * RUN_SPEED_MAX, RUN_SPEED_MAX)
	player().accelerateFlat(inputs().direction * targetSpeed, ACCELERATION * delta)

	# Animation
	_processAnimations()

#endregion


#region Private functions

func _processAnimations() -> void:
	var normRange := maxf(
		clampf(PPUtil.Math.toRangeNormalized(player().velocity.length(), WALK_SPEED_MAX, RUN_SPEED_MAX), -1.0, 1.0), 
		-MIN_PERIOD_MULTIPLIER
	)
	_period = maxf(
		_walkPeriod + normRange * (_runPeriod - _walkPeriod),
		_walkPeriod * MIN_PERIOD_MULTIPLIER
	)

	frameDataScale = _walkPeriod / _period
	animator().setScale(&"WalkScale", frameDataScale)
	animator().setScale(&"RunScale", _runPeriod / _period)
	animator().setBlendAmount(&"Move", normRange)

#endregion
