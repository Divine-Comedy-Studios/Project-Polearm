extends PlayerAction


func enterImpl() -> void:
	player.velocity = Vector3.ZERO

func exitImpl() -> void:
	pass


func tickImpl(_input : PlayerInputManager.Data, _delta : float) -> void:
	pass


func nextStateImpl(next : Type):
	if not player.onGround():
		if next == Type.none or container.hasHigherPriority(Type.fall, next):
			return Type.fall

	return next
