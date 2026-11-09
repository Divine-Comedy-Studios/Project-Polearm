extends InterfaceState

var _yesPressed := false
var _noPressed := false

#region Export variables

@export var BACK_MENU : Type

#endregion


#region Implementation functions

func type() -> Type:
	return Type.quitConfirmMenu

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
	if _noPressed:
		return BACK_MENU
	return Type.none

func _implDeactivate() -> void:
	_yesPressed = false
	_noPressed = false

func exit() -> StringName:
	if _yesPressed:
		return AppState.Type.quit

	return AppState.Type.none

#endregion

func _on_yes_pressed() -> void:
	_yesPressed = true

func _on_no_pressed() -> void:
	_noPressed = true
