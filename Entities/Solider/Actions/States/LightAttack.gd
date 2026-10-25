extends SoliderAction


#region Override functions

func _implEnter() -> void:
	context().controller.beforeAttack()

	_animationSetupBasic()

func _implExit() -> void:
	context().controller.afterAttack()


func _implTick(_delta : float) -> void:
	if not entity().onGround():
		rootMotionEnabled = false

#endregion
