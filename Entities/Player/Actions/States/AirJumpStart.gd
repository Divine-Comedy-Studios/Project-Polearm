extends PlayerAction


#region Override functions

func _viable() -> bool:
	return resources().jumpCount.value < resources().jumpCount.maxValue


func _implInit() -> void:
	pass


func _implEnter() -> void:
	resources().jumpCount.value += 1

	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME

	animator().transitionToUnused(&"BasicTransition", 
		animator().setCoreTransition(&"BasicTransition", data.ANIMATION_FADE_TIME))

func _implExit() -> void:
	pass


func _tick(_delta : float) -> void:
	context().pushActionQueue(Type.jump)

#endregion
