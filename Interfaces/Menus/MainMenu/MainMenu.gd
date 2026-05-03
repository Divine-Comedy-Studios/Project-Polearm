extends InterfaceStateMachine


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func injectSaveSlotSignal(saveSlotSelected : Signal) -> void:
	pass
