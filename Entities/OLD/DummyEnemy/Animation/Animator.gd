extends EntityAnimator
class_name DummyEnemyAnimator


#region Override functions

func _initialize() -> void:
	var driver := animationDriver(&"BasicTransitionAnim1")
	driver.animation = DEFAULT_ANIMATION_NAME

	registerAutoTransition(&"BasicTransition", &"Anim")
	registerAutoTransition(&"BlendTransition", &"Driver")
	registerAutoBlendDriver(&"BlendTransitionDriver1")
	registerAutoBlendDriver(&"BlendTransitionDriver2")

#endregion
