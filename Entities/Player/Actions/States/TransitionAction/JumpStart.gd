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
	_friction = physics().GROUNDED_FRICTION


	animator().animationDriver(&"JumpStill").animation = JUMP_STILL_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(&"JumpRun").animation = JUMP_RUN_DATA.ANIMATION_FULL_NAME

	_jumpStillPeriod = animator().animation(JUMP_STILL_DATA.ANIMATION_FULL_NAME).length
	_jumpRunPeriod = animator().animation(JUMP_RUN_DATA.ANIMATION_FULL_NAME).length

	data = JUMP_STILL_DATA


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
	animator().setCoreTransition(&"AdvancedTransition", data.ANIMATION_FADE_TIME)
	animator().transitionTo(&"AdvancedTransition", &"Jump")

	if not player().onGround():
		animator().setBlendAmount(&"Jump", 1.0)
		frameDataScale = _jumpStillPeriod / _jumpRunPeriod
		return

	var normRange := clampf(
		PPUtil.Math.toRangeNormalized(
			player().velocity.length(), 
			physics().MAX_WALK_SPEED, 
			physics().MAX_RUN_SPEED),
		0.0, 1.0)
	var duration := _jumpStillPeriod + normRange * (_jumpRunPeriod - _jumpStillPeriod)

	frameDataScale = _jumpStillPeriod / duration
	animator().setScale(&"JumpStillScale", frameDataScale)
	animator().setScale(&"JumpRunScale", _jumpRunPeriod / duration)
	animator().setBlendAmount(&"Jump", normRange)

#endregion
