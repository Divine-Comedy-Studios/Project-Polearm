extends PlayerBasicGrounded


@export var FRICTION : float = 30.0


func _enter() -> void:
	var transitionHandle := animator().transitionHandle()
	var transitionDriver := animator().transitionDriver(transitionHandle)
	transitionDriver.xfade_time = 1.0

	var animationHandle := animator().animationHandle()
	var animationDriver := animator().animationDriver(animationHandle)
	animationDriver.animation = data.ANIMATION_FULL_NAME

	animator().transitionTo(transitionHandle, animationHandle)


func _tick(delta : float) -> void:
	player().accelerateFlat(Vector3.ZERO, FRICTION * delta)
