extends SoliderAction
class_name NinjaAction


#region Override functions

func _enter() -> void:
	var comboManager := combatManager()
	if comboManager != null:
		if comboManager.isNextComboAction(TYPE):
			data = comboManager.registerComboAction(TYPE)
		else:
			comboManager.resetActiveCombo()

	super._enter()

#endregion


#region Public funcitons

func combatManager() -> EntityCombatManager:
	return context().combatManager

#endregion
