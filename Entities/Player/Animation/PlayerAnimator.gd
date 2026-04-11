extends EntityAnimator
class_name PlayerAnimator


#region Override functions

func _playInitialAnimation() -> void:
	var transHandle := transitionHandle()

	var handle := animationHandle()
	var driver := animationDriver(handle)
	driver.animation = DEFAULT_ANIMATION_NAME

	transitionTo(transHandle, handle)

#endregion
