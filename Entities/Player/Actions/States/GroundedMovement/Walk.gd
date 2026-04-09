extends PlayerGroundedMovement


@export var WALK_SPEED : float = 0


func _tick(_delta : float) -> void:
	player().velocity = Vector3(inputs().direction.x, 0, inputs().direction.y) * WALK_SPEED
