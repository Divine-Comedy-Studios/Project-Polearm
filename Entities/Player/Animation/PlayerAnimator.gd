extends EntityAnimator
class_name PlayerAnimator


#region Public functions

# Set the transition driver which the core transition driver points to
func setCoreTransition(destTransitionHandle : StringName, fadeTime : float) -> AnimationNodeTransition:
	var destTransitionDriver := transitionDriver(destTransitionHandle)
	destTransitionDriver.xfade_time = 0.0

	transitionDriver(&"CoreTransition").xfade_time = fadeTime

	# IMPORTANT: Guarantee that the destination transition handle is always named the same as the input
	if not transitionTo(&"CoreTransition", destTransitionHandle):
		destTransitionDriver.xfade_time = fadeTime # If we were already on the correct path, we transition using the inner transitioner instead
	
	return destTransitionDriver

#endregion


#region Override functions

func _initialize() -> void:
	var driver := animationDriver(&"BasicTransitionAnim1")
	driver.animation = DEFAULT_ANIMATION_NAME

	registerAutoTransition(&"BasicTransition", &"Anim")
	registerAutoTransition(&"BlendTransition", &"Driver")
	registerAutoBlendDriver(&"BlendTransitionDriver1")
	registerAutoBlendDriver(&"BlendTransitionDriver2")

#endregion
