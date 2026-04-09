extends PlayerAction


func _implEnter() -> void:
	player().detachGround()

func _implExit() -> void:
	player().attachGround()


func _tick(_delta : float) -> void:
	pass


func _implNextAction(next : StringName) -> StringName:
	return next
