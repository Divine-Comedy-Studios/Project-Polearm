extends PlayerBasicTransitionAciton


func _viable() -> bool:
	return not resources().airDashed

func _implEnter() -> void:
	resources().airDashed = true

	super._implEnter()
