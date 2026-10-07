extends EntityAnimator
class_name ArcherAnimator


#region Override functions

func _initialize() -> void:
	animationDriver(&"BasicTransitionAnim1").animation = DEFAULT_ANIMATION_NAME

	registerAutoTransition(&"BasicTransition", &"Anim")


func reset() -> void:
	animationDriver(unusedHandle(&"BasicTransition")).animation = DEFAULT_ANIMATION_NAME

#endregion
