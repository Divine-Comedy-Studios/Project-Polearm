extends Node
class_name ISMInputManager


#region Helper classes

class Data:
	var cancel : bool = false
	var pause : bool = false

	func reset() -> void:
		cancel = false
		pause = false

	func copy(other : Data) -> void:
		cancel = other.cancel
		pause = other.pause

#endregion


#region Member variables

var inputs : Data = Data.new()

var _inputData : Data = Data.new()

#endregion


#region Built-in functions

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_inputData.cancel = true

	if event.is_action_pressed("ui_pause"):
		_inputData.pause = true

#endregion


#region Public functions

func pollInputs() -> void:
	inputs.copy(_inputData)
	_inputData.reset()

#endregion
