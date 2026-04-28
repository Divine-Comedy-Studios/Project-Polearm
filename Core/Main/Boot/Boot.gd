extends Node2D


@export var timer : float = 1


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	timer -= delta

func readyToSwitch() -> bool:
	return timer < 0.0
