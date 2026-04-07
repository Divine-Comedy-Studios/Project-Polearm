extends AppStateMachine
class_name Game


#region Enums

enum Type { 
	none,
	
	loading,
	playing,
	paused,
}

#endregion


#region Override functions

func _initialState() -> int:
	return Type.loading

#endregion
