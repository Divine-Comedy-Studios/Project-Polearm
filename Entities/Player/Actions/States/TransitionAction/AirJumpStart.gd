extends PlayerBasicTransitionAciton


func _viable() -> bool:
	return resources().jumpCount.value < resources().jumpCount.maxValue

func _implEnter() -> void:
	resources().jumpCount.value += 1
	resources().airDashed = false

	super._implEnter()
