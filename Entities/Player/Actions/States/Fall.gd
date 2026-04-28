extends PlayerAction


#region Exported variables

@export_group("Movement settings")
@export var MAX_SPEED : float = 5.0
@export var ACCELERATION : float = 15.0
@export var FRICTION : float = 1.0

@export_group("Gravity settings")
@export var GRAVITY : float = 20.0
@export var TERMINAL_VELOCITY : float = 30.0

#endregion


#region Override functions

func _implEnter() -> void:
	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME
	animator().transitionToUnused(&"BasicTransition", 
		animator().setCoreTransition(&"BasicTransition", data.ANIMATION_FADE_TIME))

func _implExit() -> void:
	player().setMovementVertical(0.0)


func _tick(delta : float) -> void:
	# Movement
	var targetSpeed := minf(inputs().inputMagnitude * MAX_SPEED, MAX_SPEED)

	if is_zero_approx(targetSpeed):
		player().accelerateFlat(Vector3.ZERO, FRICTION * delta)
	else:
		player().accelerateFlat(inputs().direction * targetSpeed, ACCELERATION * delta)

	# Gravity
	player().accelerateVertical(TERMINAL_VELOCITY, -GRAVITY * delta)

	# Ledge detection
	context().physics.sweepLedge()

	if context().physics.ledgeData.collided:
		context().pushActionQueue(Type.ledgeGrab)


func _implNextAction(next : StringName) -> StringName:
	if player().onGround():
		return next
	if next != Type.none and not hasHigherPriorityThan(next):
		return next

	return Type.none

#endregion
