extends PlayerAction


#region Exported variables

@export_group("Animation settings")
@export var LANDING_STILL_DATA : PlayerActionData = null
@export var LANDING_RUN_DATA : PlayerActionData = null

#endregion


#region Member variables

# Movement settings
var _friction : float = 0.0


# Animation
var _landStillPeriod : float = 0.0
var _landRunPeriod : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_friction = physics().REDUCED_GROUNDED_FRICTION

	data = LANDING_STILL_DATA

	_landStillPeriod = animator().animation(LANDING_STILL_DATA.ANIMATION_FULL_NAME).length
	_landRunPeriod = animator().animation(LANDING_RUN_DATA.ANIMATION_FULL_NAME).length


func _implEnter() -> void:
	_processAnimations()


func _tick(delta : float) -> void:
	player().accelerate(Vector3.ZERO, _friction * delta)


func _implNextAction(next : StringName) -> StringName:
	if next == Type.idle:
		var speedSqared := Vector2(player().velocity.x, player().velocity.z).length_squared()
		var maxSpeed := physics().MAX_AERIAL_SPEED

		if speedSqared > maxSpeed * maxSpeed:
			return Type.sprintStop

		maxSpeed = physics().WALK_SPEED
		if speedSqared > maxSpeed * maxSpeed:
			return Type.moveStop

	return next;

#endregion


#region Private functions

func _processAnimations() -> void:
	# Calculate factors to blend the animations between their different states

	var normRange := clampf(
		PPUtil.Math.toRangeNormalized(
			Vector2(player().velocity.x, player().velocity.z).length(), 
			physics().WALK_SPEED,
			physics().RUN_SPEED),
		0.0, 1.0)
	var duration := _landStillPeriod + normRange * (_landRunPeriod - _landStillPeriod)
	frameDataScale = _landStillPeriod / duration


	# Setup animations

	var blendHandle := animator().unusedHandle(&"BlendTransition")
	var autoBlender := animator().autoBlendDriver(blendHandle)

	animator().animationDriver(autoBlender.first.anim).animation = LANDING_STILL_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(autoBlender.second.anim).animation = LANDING_RUN_DATA.ANIMATION_FULL_NAME

	animator().setScale(autoBlender.first.scale, frameDataScale)
	animator().setScale(autoBlender.second.scale, _landRunPeriod / duration)
	animator().setBlendAmount(blendHandle, normRange)

	animator().transitionToUnused(&"BlendTransition", 
		animator().setCoreTransition(&"BlendTransition", LANDING_STILL_DATA.ANIMATION_FADE_TIME))

#endregion
