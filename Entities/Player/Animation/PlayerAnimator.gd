extends EntityAnimator
class_name PlayerAnimator


#region Override functions

func _playInitialAnimation() -> void:
	var transitionHandle := transitionHandle()

	var animationHandle := animationHandle()
	var animationDriver := animationDriver(animationHandle)
	animationDriver.animation = DEFAULT_ANIMATION_NAME

	transitionTo(transitionHandle, animationHandle)

#endregion
