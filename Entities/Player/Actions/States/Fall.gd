extends BasicAerialMovement


#region Exported variables

@export_group("Gravity settings")
@export var GRAVITY : float = 20.0
@export var FLOATING_TERMINAL_VELOCITY : float = 2.0
@export var TERMINAL_VELOCITY : float = 30.0

#endregion


#region Member variables

var _terminalVel : float = GRAVITY

#endregion


#region Override functions

func _implEnter() -> void:
	_animationSetupBasic()

func _implExit() -> void:
	player().setMovementVertical(0.0)


func _tick(delta : float) -> void:
	# Gravity

	if player().velocity.y < 0:
		if inputs().modifiers.has(Type.jump):
			_terminalVel = FLOATING_TERMINAL_VELOCITY
		else:
			_terminalVel = TERMINAL_VELOCITY

		# Only do ledge detection if the player is properly falling and not deaccelerating
		context().physics.sweepLedge()

		if context().physics.ledgeData.collided:
			context().pushActionQueue(Type.ledgeGrab)

	player().accelerateVertical(-_terminalVel, GRAVITY * delta)
	moveAerial(delta)


func _implNextAction(next : StringName) -> StringName:
	if player().onGround(): # Player landing on ground
		return Type.landing
	if next != Type.none and not hasHigherPriorityThan(next):
		return next

	return Type.none

#endregion
