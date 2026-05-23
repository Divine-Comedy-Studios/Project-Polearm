extends PlayerBasicTransitionAciton


var _aerialFriction : float = 0.0


func _viable() -> bool:
	return resources().jumpCount.value < resources().jumpCount.maxValue


func _implInit() -> void:
	_aerialFriction = physics().REDUCED_AERIAL_FRICTION

func _implEnter() -> void:
	resources().jumpCount.value += 1
	resources().airDashed = false

	super._implEnter()


func _tick(delta : float) -> void:
	player().accelerate(Vector3.ZERO, _aerialFriction * delta)

	super._tick(delta)
