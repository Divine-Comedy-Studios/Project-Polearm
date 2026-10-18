extends BasicAerialMovement


#region Member variables

var _gravity : float = 0.0
var _terminalVelocity : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_gravity = physics().GRAVITY
	_terminalVelocity = physics().TERMINAL_VELOCITY


func _implEnter() -> void:
	_animationSetupBasic()

func _implExit() -> void:
	player().setMovementVertical(0.0)


func _implTick(delta : float) -> void:
	# var terminalVel := _terminalVelocity

	# if inputs().modifiers.has(Type.jump): # Check if player is floating
	#	terminalVel = FLOATING_TERMINAL_VELOCITY
	# else:
	#	terminalVel = TERMINAL_VELOCITY

	context().physics.sweepLedge()
	if context().physics.ledgeData.collided:
		context().pushActionQueue(Type.ledgeGrab)

	moveAerial(delta)
	player().accelerateVertical(-_terminalVelocity, _gravity * delta)


func _implNextAction(next : StringName) -> StringName:
	if player().onGround():
		return Type.landing
	if next != Type.none and not hasHigherPriorityThan(next):
		return next

	return Type.none

#endregion
