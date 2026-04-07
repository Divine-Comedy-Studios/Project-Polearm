extends AppStateMachine
class_name Main


#region Enums

enum Type {
	none,
	
	boot,
	quit,
	mainMenu,
	game,
}

#endregion


#region Override functions

func _initialState() -> int:
	return Type.boot

#endregion
