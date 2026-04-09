extends PlayerAction


@export var ACCELERATION : float = 1
@export var TERMINAL_VELOCITY : float = 20


func _implEnter() -> void:
	pass

func _implExit() -> void:
	player().velocity.y = 0


func _tick(_delta : float) -> void:
	player().velocity.y = maxf(player().velocity.y - ACCELERATION, -TERMINAL_VELOCITY)


func _implNextAction(next : StringName) -> StringName:
	if player().onGround():
		return next
	if next != Type.none and next != Type.jumpStill and not hasHigherPriorityThan(next):
		return next

	return Type.none
