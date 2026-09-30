extends PlayerBasicDash


func _implTick(delta : float) -> void:
	super._implTick(delta)

	if inputs().modifiers.has(Type.sprint):
		context().pushActionQueue(Type.sprint)
	elif player().onGround():
		context().pushActionQueue(Type.dashStop)
