# Fancy Idle class, activated upon staying idle for prolonged periods of time

extends PlayerBasicGrounded


@export var FRICTION : float = 30.0


func _enter() -> void:
	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME

	animator().transitionToUnused(&"BasicTransition", 
		animator().setCoreTransition(&"BasicTransition", data.ANIMATION_FADE_TIME))


func _tick(delta : float) -> void:
	player().accelerate(Vector3.ZERO, FRICTION * delta)
