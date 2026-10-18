extends AppState


#region Override functions

func enter() -> void:
	if Globals.settingsManager != null:
		Globals.settingsManager.saveSettings()
	
	get_tree().quit()


func type() -> StringName:
	return Type.quit

#endregion
