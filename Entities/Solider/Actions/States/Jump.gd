extends NinjaSoliderAction

# Jumps up and forwards, in the direction of the intents (towards the player). Falls after the highest point,
# at which the regular fall takes over.
#
# Scene setup: TYPE = Type.jump, PRIORITY = Priority.jumpingTypes (30), data = the jump animation.
# Frame data: _transitionable = true after take off, otherwise the solider can't switch to falling.


#region Exported variables

@export_group("Movement settings")
@export var JUMP_SPEED : float = 12.0
@export var FORWARD_SPEED : float = 5.0
@export var RISE_GRAVITY : float = 35.0

#endregion


#region Override functions

func _viable() -> bool:
	return entity().onGround()


func _implEnter() -> void:
	entity().detachGround()
	entity().disableCollisionProcessing()

	var direction := intents().direction
	if direction.is_zero_approx():
		direction = PPUtil.Math.toFlatVec2(entity().forward()).normalized()

	entity().setMovementFlat(direction * FORWARD_SPEED)
	entity().setMovementVertical(JUMP_SPEED)

	controller().beforeJump()

	_animationSetupBasic()

func _implExit() -> void:
	entity().enableCollisionProcessing()

	controller().afterJump()


func _implTick(delta : float) -> void:
	entity().accelerateVertical(0.0, RISE_GRAVITY * delta)


func _implNextAction(next : StringName) -> StringName:
	if ((entity().onCeiling() or entity().movement().y < 0.01) and
		(next == Type.none or context().hasHigherPriority(Type.fall, next))):
		return Type.fall

	return next

#endregion
