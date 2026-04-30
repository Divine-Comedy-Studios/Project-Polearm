extends PlayerAction


#region Override functions

func _implEnter() -> void:
	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME
	animator().transitionToUnused(&"BasicTransition", 
		animator().setCoreTransition(&"BasicTransition", data.ANIMATION_FADE_TIME))

#endregion
