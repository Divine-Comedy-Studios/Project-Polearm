extends BasicAerialMovement


#region Exported variables

@export_group("Gravity settings")
@export var FALL_GRAVITY : float = 80.0
@export var FLOATING_TERMINAL_VELOCITY : float = 2.0
@export var TERMINAL_VELOCITY : float = 30.0

#endregion


#region Override functions

func _implEnter() -> void:
	_animationSetupBasic()

func _implExit() -> void:
	player().setMovementVertical(0.0)


func _implTick(delta : float) -> void:
	var terminalVel := TERMINAL_VELOCITY

	#if inputs().modifiers.has(Type.jump): # Check if player is floating
	#	terminalVel = FLOATING_TERMINAL_VELOCITY
	#else:
	#	terminalVel = TERMINAL_VELOCITY

	context().physics.sweepLedge()
	if context().physics.ledgeData.collided:
		context().pushActionQueue(Type.ledgeGrab)

	moveAerial(delta)
	player().accelerateVertical(-terminalVel, FALL_GRAVITY * delta)


func _implNextAction(next : StringName) -> StringName:
	if player().onGround():
		return Type.landing
	if next != Type.none and not hasHigherPriorityThan(next):
		return next

	return Type.none

#endregion
