extends EntityAnimator
class_name SoliderAnimator


#region Override functions

func _initialize() -> void:
	animationDriver(&"BasicTransitionAnim1").animation = DEFAULT_ANIMATION_NAME

	registerAutoTransition(&"BasicTransition", &"Anim")
	registerAutoTransition(&"BlendTransition", &"Driver")
	registerAutoBlendDriver(&"BlendTransitionDriver1")
	registerAutoBlendDriver(&"BlendTransitionDriver2")


func reset() -> void:
	animationDriver(unusedHandle(&"BasicTransition")).animation = DEFAULT_ANIMATION_NAME
	transitionToUnused(&"BasicTransition", setCoreTransition(&"BasicTransition", 0.0))

#endregion
