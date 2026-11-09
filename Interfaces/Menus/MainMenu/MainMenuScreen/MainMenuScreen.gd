extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Member variables

var _startGamePressed : bool = false
var _openOptionsPressed : bool = false
var _creditsPressed : bool = false
var _quitGamePressed : bool = false

#endregion


#region Implementation functions

func type() -> Type:
	return Type.startMenu

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
	
	if _openOptionsPressed:
		return Type.options
	if _creditsPressed:
		return Type.credits

	if _quitGamePressed:
		return Type.quitConfirmMenu
	
	return Type.none

func _implDeactivate() -> void:
	_startGamePressed = false
	_openOptionsPressed = false
	_creditsPressed = false
	_quitGamePressed = false

func exit() -> StringName:
	if _startGamePressed:
		return AppState.Type.game

	return AppState.Type.none

#endregion


#region Signal functions

func _on_continue_pressed() -> void:
	_startGamePressed = true

func _on_options_pressed() -> void:
	_openOptionsPressed = true

func _on_credits_pressed() -> void:
	_creditsPressed = true

func _on_exit_game_pressed() -> void:
	_quitGamePressed = true

#endregion
