extends BasicAerialMovement


#region Exported variables

@export_group("Gravity settings")
@export var GRAVITY : float = 20.0
@export var FLOATING_TERMINAL_VELOCITY : float = 2.0
@export var TERMINAL_VELOCITY : float = 30.0

#endregion


#region Override functions

func _implEnter() -> void:
	_setupBasicAnimation()

func _implExit() -> void:
	player().setMovementVertical(0.0)


func _tick(delta : float) -> void:
	# Gravity
	var terminalVel := TERMINAL_VELOCITY

	if player().velocity.y < 0:
		if inputs().modifiers.has(Type.jump):
			terminalVel = FLOATING_TERMINAL_VELOCITY

		# Only do ledge detection if the player is properly falling and not deaccelerating
		context().physics.sweepLedge()

		if context().physics.ledgeData.collided:
			context().pushActionQueue(Type.ledgeGrab)

	player().accelerateVertical(-terminalVel, GRAVITY * delta)
	moveAerial(delta)


func _implNextAction(next : StringName) -> StringName:
	if player().onGround():
		return next
	if next != Type.none and not hasHigherPriorityThan(next):
		return next

	return Type.none

#endregion
