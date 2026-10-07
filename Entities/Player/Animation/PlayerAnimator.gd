extends EntityAnimator
class_name PlayerAnimator


#region Override functions

func _initialize() -> void:
	animationDriver(&"BasicTransitionAnim1").animation = DEFAULT_ANIMATION_NAME

	registerAutoTransition(&"BasicTransition", &"Anim")
	registerAutoTransition(&"BlendTransition", &"Driver")
	registerAutoBlendDriver(&"BlendTransitionDriver1")
	registerAutoBlendDriver(&"BlendTransitionDriver2")

#endregion
