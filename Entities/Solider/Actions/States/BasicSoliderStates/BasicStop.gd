extends SoliderAction
class_name SoliderBasicStopAction


@export var FRICTION_MULTIPLIER : float = 1.0
@export var GROUNDED_FRICTION : float = 30


func _implInit() -> void:
	FRICTION_MULTIPLIER *= GROUNDED_FRICTION

func _implTick(delta : float) -> void:
	entity().accelerate(Vector3.ZERO, FRICTION_MULTIPLIER * delta)
