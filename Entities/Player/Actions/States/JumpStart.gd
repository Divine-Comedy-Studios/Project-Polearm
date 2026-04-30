extends PlayerAction


#region Exported variables

@export_group("Movement settings")
@export var STILL_SPEED_MAX : float = 2.0
@export var RUN_SPEED_MAX : float = 5.0
@export var FRICTION : float = 30.0

@export_group("Animation settings")
@export var JUMP_STILL_DATA : PlayerActionData = null
@export var JUMP_RUN_DATA : PlayerActionData = null

#endregion


#region Member variables

var _jumpStillPeriod : float = 0.0
var _jumpRunPeriod : float = 0.0

#endregion


#region Override functions

func _viable() -> bool:
	return player().onGround()


func _implInit() -> void:
	animator().animationDriver(&"JumpStill").animation = JUMP_STILL_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(&"JumpRun").animation = JUMP_RUN_DATA.ANIMATION_FULL_NAME

	_jumpStillPeriod = animator().animation(JUMP_STILL_DATA.ANIMATION_FULL_NAME).length
	_jumpRunPeriod = animator().animation(JUMP_RUN_DATA.ANIMATION_FULL_NAME).length

	data = JUMP_STILL_DATA


func _implEnter() -> void:
	_processAnimations()

func _implExit() -> void:
	pass


func _tick(delta : float) -> void:
	player().accelerate(Vector3.ZERO, FRICTION * delta)
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

	var normRange := clampf(PPUtil.Math.toRangeNormalized(player().velocity.length(), STILL_SPEED_MAX, RUN_SPEED_MAX), 0.0, 1.0)
	var duration := _jumpStillPeriod + normRange * (_jumpRunPeriod - _jumpStillPeriod)

	frameDataScale = _jumpStillPeriod / duration
	animator().setScale(&"JumpStillScale", frameDataScale)
	animator().setScale(&"JumpRunScale", _jumpRunPeriod / duration)
	animator().setBlendAmount(&"Jump", normRange)

#endregion
