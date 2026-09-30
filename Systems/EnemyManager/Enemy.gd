class_name Enemy
extends GameObject

func _killImpl() -> void:
	Globals.enemyManager.remove_child(object)
