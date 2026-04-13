extends Node
class_name ISMInputManager


#region Helper classes

class Data:
	var cancel : bool = false
	var pause : bool = false

	func reset() -> void:
		cancel = false
		pause = false

#endregion


#region Member variables

var inputs : Data = Data.new()

#endregion


#region Built-in functions

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

#endregion


#region Public functions

func pollInputs() -> void:
	inputs.reset()

	if Input.is_action_just_pressed("ui_cancel"):
		if not SettingsManager.isRemapping:
			inputs.cancel = true

	if Input.is_action_just_pressed("ui_pause"):
		inputs.pause = true

#endregion
