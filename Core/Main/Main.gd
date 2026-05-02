extends AppStateMachine


#region Built-in functions

# func _unhandled_input(event: InputEvent) -> void:
#	if event is InputEventMouseButton: # Automatic mouse focus
#		if event.pressed && Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
#			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#			return

#endregion


#region Override functions

func _initialState() -> StringName:
	return AppState.Type.boot

#endregion
