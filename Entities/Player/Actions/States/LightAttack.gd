extends PlayerAction


#region Override functions

func _implEnter() -> void:
	_animationSetupBasic()

func _implExit() -> void:
	weapon().disable()


func _implTick(delta : float) -> void:
	if not player().onGround():
		rootMotionEnabled = false

#endregion
