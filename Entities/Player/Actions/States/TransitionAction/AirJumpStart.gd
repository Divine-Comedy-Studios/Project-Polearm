extends PlayerAction


var _aerialFriction : float = 0.0


func _viable() -> bool:
	return resources().jumpCount.value < resources().jumpCount.maxValue


func _implInit() -> void:
	_aerialFriction = physics().REDUCED_AERIAL_FRICTION

func _implEnter() -> void:
	resources().jumpCount.value += 1
	resources().airDashed = false

	_animationSetupBasic()


func _implTick(delta : float) -> void:
	player().accelerate(Vector3.ZERO, _aerialFriction * delta)

	if finished():
		context().interrupt(Type.airJump)
