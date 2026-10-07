extends ArcherAction


func _implEnter() -> void:
	if resources().health.value <= 0.0:
		context().interrupt(Type.death)

		return

	_animationSetupBasic()
