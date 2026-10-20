extends PlayerAction
class_name PlayerAttack


#region Override functions

func _implEnter() -> void:
	_animationSetupBasic()

func _implExit() -> void:
	if weapon().hitbox.hitCount > 0:
		resources().energy.value += data.ENERGY_GAIN

	weapon().disable()

#endregion
