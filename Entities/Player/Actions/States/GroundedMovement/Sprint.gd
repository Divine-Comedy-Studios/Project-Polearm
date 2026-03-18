extends PlayerGroundedMovement


@export var RUN_SPEED : float = 0


func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func tickImpl(input : PlayerInputManager.Data, _delta : float) -> void:
	player.velocity = Vector3(input.direction.x, 0, input.direction.y) * RUN_SPEED
