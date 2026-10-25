extends SoliderAction


#region Constants

const MIN_PERIOD_MULTIPLIER : float = 0.7

#endregion


#region Exported variables

@export_group("Movement settings")
@export var MIN_SPEED : float = 2.0
@export var MAX_SPEED : float = 5.5
@export_range(0.0, 0.9) var SPEED_RANDOMNESS : float = 0.25
@export var ACCELERATION : float = 25.0

@export_group("Animation settings")
@export var IDLE_DATA : EntityActionData = null
@export var WALK_DATA : EntityActionData = null
@export var RUN_DATA : EntityActionData = null
@export var BLEND_LERP : float = 0.2

@export_group("Footstep settings")
@export var WALK_FOOTSTEP_INTERVAL : float = 0.6
@export var RUN_FOOTSTEP_INTERVAL : float = 0.35

#endregion


#region Member variables

# Animation data

var _walkPeriod : float = 0.0
var _runPeriod : float = 0.0

var _blendScale : float = 0.0


# Footsteps
var _footstepTimer : float = 0.0

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

	var randomness := 1.0 + randf_range(-SPEED_RANDOMNESS, SPEED_RANDOMNESS)
	MIN_SPEED *= randomness
	MAX_SPEED *= randomness


func _implEnter() -> void:
	_footstepTimer = 0.0

	animator().setCoreTransition(&"AdvancedTransition", data.ANIMATION_FADE_TIME)
	animator().transitionTo(&"AdvancedTransition", &"Move")


func _implTick(delta : float) -> void:
	var intentData := intents()

	entity().accelerateFlat(intentData.direction * lerpf(MIN_SPEED, MAX_SPEED, intentData.magnitude), ACCELERATION * delta)

	_processAnimations()
	_processFootsteps(delta)

#endregion


#region Private functions

func _processAnimations() -> void:
	var speedFactor := 0.0
	if MAX_SPEED > MIN_SPEED:
		speedFactor = clampf(
			PPUtil.Math.toRangeNormalized(entity().velocity.length(), MIN_SPEED, MAX_SPEED),
			-1.0, 1.0
		)

	_blendScale = lerpf(_blendScale, maxf(speedFactor, -MIN_PERIOD_MULTIPLIER), BLEND_LERP)
	var period := maxf(
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

	var runAmount := clampf(inverse_lerp(MIN_SPEED, MAX_SPEED, entity().velocity.length()), 0.0, 1.0)
	_footstepTimer = lerpf(WALK_FOOTSTEP_INTERVAL, RUN_FOOTSTEP_INTERVAL, runAmount)

	Globals.sfxManager.play(SFXData.Type.footstep, entity().global_position)

#endregion
