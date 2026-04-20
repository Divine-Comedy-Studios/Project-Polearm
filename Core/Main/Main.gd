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


#region Built-in functions

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton: # Automatic mouse focus
		if event.pressed && Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return

#endregion


#region Override functions

func _initialState() -> StringName:
	return Type.boot

#endregion
