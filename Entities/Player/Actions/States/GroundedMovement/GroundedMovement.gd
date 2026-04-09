extends PlayerAction
class_name PlayerGroundedMovement

func _implNextAction(next : StringName) -> StringName:
	if not player().onGround():
		if next == Type.none or context.hasHigherPriority(Type.fall, next):
			return Type.fall

	return next
