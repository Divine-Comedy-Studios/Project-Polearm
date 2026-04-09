extends PlayerGroundedMovement


@export var RUN_SPEED : float = 0


func _tick(delta : float) -> void:
	player().velocity = Vector3(inputs().direction.x, 0, inputs().direction.y) * RUN_SPEED
