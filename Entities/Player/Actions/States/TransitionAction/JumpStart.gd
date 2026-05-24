extends PlayerAction


#region Exported variables

@export_group("Animation settings")
@export var JUMP_STILL_DATA : PlayerActionData = null
@export var JUMP_RUN_DATA : PlayerActionData = null

#endregion


#region Member variables

# Movement settings
var _friction : float = 0.0


# Animation

var _jumpStillPeriod : float = 0.0
var _jumpRunPeriod : float = 0.0

#endregion


#region Override functions

func _viable() -> bool:
	return player().onGround()


func _implInit() -> void:
	_friction = physics().REDUCED_GROUNDED_FRICTION

	data = JUMP_STILL_DATA

	_jumpStillPeriod = animator().animation(JUMP_STILL_DATA.ANIMATION_FULL_NAME).length
	_jumpRunPeriod = animator().animation(JUMP_RUN_DATA.ANIMATION_FULL_NAME).length


func _implEnter() -> void:
	resources().airDashed = false

	_processAnimations()

func _implExit() -> void:
	pass


func _tick(delta : float) -> void:
	player().accelerate(Vector3.ZERO, _friction * delta)
	context().pushActionQueue(Type.jump)

#endregion


#region Private functions

func _processAnimations() -> void:
	# Calculate factors to blend the animations between their different states

	var normRange := clampf(
		PPUtil.Math.toRangeNormalized(
			player().velocity.length(), 
			physics().WALK_SPEED, 
			physics().RUN_SPEED),
		0.0, 1.0)
	var duration := _jumpStillPeriod + normRange * (_jumpRunPeriod - _jumpStillPeriod)
	frameDataScale = _jumpStillPeriod / duration


	# Setup animations

	var blendHandle := animator().unusedHandle(&"BlendTransition")
	var autoBlender := animator().autoBlendDriver(blendHandle)

	animator().animationDriver(autoBlender.first.anim).animation = JUMP_STILL_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(autoBlender.second.anim).animation = JUMP_RUN_DATA.ANIMATION_FULL_NAME

	animator().setScale(autoBlender.first.scale, frameDataScale)
	animator().setScale(autoBlender.second.scale, _jumpRunPeriod / duration)
	animator().setBlendAmount(blendHandle, normRange)

	animator().transitionToUnused(&"BlendTransition", 
		animator().setCoreTransition(&"BlendTransition", data.ANIMATION_FADE_TIME))

#endregion
