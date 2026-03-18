extends PlayerAction
class_name PlayerGroundedMovement

func nextStateImpl(next : Type) -> Type:
	if not player.onGround():
		if next == Type.none or manager.hasHigherPriority(Type.fall, next):
			return Type.fall

	return next
