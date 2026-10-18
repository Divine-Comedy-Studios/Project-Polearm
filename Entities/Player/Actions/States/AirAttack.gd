extends PlayerAttack


#region Override functions

func _viable() -> bool:
	return not resources().airComboed or (combatManager().hasActiveCombo() and combatManager().isNextComboAction(TYPE))

func _implEnter() -> void:
	resources().airComboed = true

	_animationSetupBasic()

#endregion

