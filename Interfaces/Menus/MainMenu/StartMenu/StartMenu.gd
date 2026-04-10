extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Member variables

var _startGamePressed : bool = false
var _savesPressed : bool = false
var _openOptionsPressed : bool = false
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
	
	if _savesPressed:
		return Type.saves
	
	return Type.none

func deactivateImpl() -> void:
	_startGamePressed = false
	_savesPressed = false
	_openOptionsPressed = false
	_quitGamePressed = false

func exit() -> StringName:
	if _startGamePressed:
		return Main.Type.game
	if _quitGamePressed:
		return Main.Type.quit

	return Main.Type.none

#endregion


#region Signal functions

func _on_continue_pressed() -> void:
	_startGamePressed = true

func _on_saves_pressed() -> void:
	_savesPressed = true

func _on_options_pressed() -> void:
	_openOptionsPressed = true

func _on_exit_game_pressed() -> void:
	_quitGamePressed = true

#endregion
