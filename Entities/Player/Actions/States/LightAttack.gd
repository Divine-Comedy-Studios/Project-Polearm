extends PlayerAction


#region Override functions

func _implEnter() -> void:
	_animationSetupBasic()

func _implExit() -> void:
	weapon().disable()

#endregion
