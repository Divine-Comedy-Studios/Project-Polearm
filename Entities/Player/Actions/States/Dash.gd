extends PlayerBasicDash


func _tick(delta : float) -> void:
	super._tick(delta)

	if inputs().modifiers.has(Type.sprint):
		context().pushActionQueue(Type.sprint)
	elif player().onGround():
		context().pushActionQueue(Type.dashStop)
