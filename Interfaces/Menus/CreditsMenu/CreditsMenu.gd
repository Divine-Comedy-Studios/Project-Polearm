extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Member variables

var _onBackPressed : bool = false

#endregion


#region Implementation functions

func type() -> Type:
	return Type.credits

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		currentButton = null
		return BACK_MENU
	
	if _onBackPressed:
		return BACK_MENU
	
	return Type.none

func _implDeactivate() -> void:
	_onBackPressed = false

#endregion


#region Signal functions

func _on_back_pressed() -> void:
	_onBackPressed = true

#endregion
