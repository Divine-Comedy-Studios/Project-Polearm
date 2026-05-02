extends InterfaceState


#region Member variables

var _continuePressed := false
var _optionsPressed := false
var _mainMenuPressed := false
var _exitMenu := false

#endregion


#region Implementation functions

func type() -> Type:
	return Type.pause

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		_exitMenu = true

	if _optionsPressed:
		return Type.options
	
	return Type.none

func _deactivateImpl() -> void:
	_continuePressed = false
	_optionsPressed = false
	_mainMenuPressed = false
	_exitMenu = false

func exit() -> StringName:
	if _continuePressed or _exitMenu:
		return AppState.Type.world
	if _mainMenuPressed:
		return AppState.Type.mainMenu

	return AppState.Type.none

#endregion


#region Signal functions

func _on_continue_pressed() -> void:
	_continuePressed = true

func _on_options_pressed() -> void:
	_optionsPressed = true

func _on_main_menu_pressed() -> void:
	_mainMenuPressed = true

#endregion
