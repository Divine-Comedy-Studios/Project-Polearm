extends BasicAerialMovement


#region Exported variables

@export_group("Gravity settings")
@export var FALL_GRAVITY : float = 50.0
@export var FAST_FALL_GRAVITY : float = 80.0
@export var FLOATING_TERMINAL_VELOCITY : float = 2.0
@export var TERMINAL_VELOCITY : float = 30.0

#endregion


#region Override functions

func _implEnter() -> void:
	_entrySpeed = minf(Vector3(player().velocity.x, 0.0, player().velocity.z).length(), _maxEntrySpeed)
	_animationSetupBasic()

func _implExit() -> void:
	player().setMovementVertical(0.0)


func _tick(delta : float) -> void:
	var gravity : float
	var terminalVel : float

	if inputs().modifiers.has(Type.jump):
		gravity = FALL_GRAVITY
		terminalVel = FLOATING_TERMINAL_VELOCITY
	else:
		gravity = FAST_FALL_GRAVITY
		terminalVel = TERMINAL_VELOCITY

	context().physics.sweepLedge()
	if context().physics.ledgeData.collided:
		context().pushActionQueue(Type.ledgeGrab)

	player().accelerateVertical(-terminalVel, gravity * delta)
	moveAerial(delta)


func _implNextAction(next : StringName) -> StringName:
	if player().onGround():
		return Type.landing
	if next != Type.none and not hasHigherPriorityThan(next):
		return next

	return Type.none

#endregion
