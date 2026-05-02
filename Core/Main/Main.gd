extends AppStateMachine


#region Override functions

func _initialState() -> StringName:
	return AppState.Type.boot

#endregion
