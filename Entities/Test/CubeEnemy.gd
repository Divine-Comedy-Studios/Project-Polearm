extends BasicEnemy
class_name CubeEnemy


@export var max_health : int = 3
var health : int = 0

func _physics_process(delta: float) -> void:
	if health == 0:
		kill()

func _spawn() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	health = max_health

func kill() -> void:
	health = 0
	process_mode = Node.PROCESS_MODE_DISABLED
	handle.kill()
