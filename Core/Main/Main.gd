extends AppStateMachine
class_name Main


#region Helper classes

class Type:
	const none := StringName()

	const boot := &"boot"
	const quit := &"quit"
	const mainMenu := &"mainMenu"
	const game := &"game"

#endregion      


#region Override functions

func _initialState() -> StringName:
	return Type.boot

#endregion
