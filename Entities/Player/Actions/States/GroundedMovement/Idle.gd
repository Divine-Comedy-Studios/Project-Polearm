extends PlayerGroundedMovement


func enterImpl() -> void:
	player.velocity = Vector3.ZERO

func exitImpl() -> void:
	pass


func tickImpl(_input : PlayerInputManager.Data, _delta : float) -> void:
	pass
