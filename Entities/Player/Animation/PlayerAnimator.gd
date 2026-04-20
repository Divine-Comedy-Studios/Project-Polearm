extends EntityAnimator
class_name PlayerAnimator


#region Public functions

func setCoreTransition(destTransitionHandle : StringName, fadeTime : float) -> AnimationNodeTransition:
	var destTransitionDriver := transitionDriver(destTransitionHandle)
	destTransitionDriver.xfade_time = 0.0

	transitionDriver(&"CoreTransition").xfade_time = fadeTime

	if not transitionTo(&"CoreTransition", &"Basic"):
		destTransitionDriver.xfade_time = fadeTime # If we were already on the correct path, we transition using the inner transitioner instead
	
	return destTransitionDriver

#endregion


#region Override functions

func _initialize() -> void:
	var driver := animationDriver(&"BasicAnim1")
	driver.animation = DEFAULT_ANIMATION_NAME

	registerAutoTransition(&"BasicTransition", &"BasicAnim1", &"BasicAnim2")

#endregion
