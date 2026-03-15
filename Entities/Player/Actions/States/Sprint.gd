extends PlayerAction


@export var RUN_SPEED : float = 0


func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func tickImpl(input : PlayerInputManager.Data, _delta : float) -> void:
	player.velocity = Vector3(input.direction.x, 0, input.direction.y) * RUN_SPEED


func nextStateImpl(next : Type):
	if not player.onGround():
		if next == Type.none or container.hasHigherPriority(Type.fall, next):
			return Type.fall

	return next
