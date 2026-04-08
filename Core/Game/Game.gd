extends AppStateMachine
class_name Game


#region Helper classes

class Type:
	const none := StringName()

	const loading := &"loading"
	const playing := &"playing"
	const paused := &"paused"

#endregion                                                                                    


#region Override functions

func _initialState() -> StringName:
	return Type.loading

#endregion
