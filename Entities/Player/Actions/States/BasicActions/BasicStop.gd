extends PlayerAction
class_name PlayerBasicStopAction


@export var FRICTION_MULTIPLIER : float = 1.0


func _implInit() -> void:
	FRICTION_MULTIPLIER *= physics().GROUNDED_FRICTION

func _tick(delta : float) -> void:
	player().accelerate(Vector3.ZERO, FRICTION_MULTIPLIER * delta)
