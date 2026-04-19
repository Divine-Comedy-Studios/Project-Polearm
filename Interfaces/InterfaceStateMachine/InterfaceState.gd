extends Control
class_name InterfaceState


#region Enums

enum Type { 
	none,
	
	quitConfirmMenu,
	startMenu,
	saves,
	options,
	pause,
	gameOptions,
	videoOptions,
	audioOptions,
	controllerOptions,
	keyboardOptions,
}

#endregion


#region Member variable

@onready var currentButton : Control = null

#endregion


#region Member functions

func activate() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	show()

	if not currentButton:
		currentButton = find_next_valid_focus()
	
	if currentButton:
		currentButton.grab_focus()

func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	currentButton = get_viewport().gui_get_focus_owner()
	hide()

	deactivateImpl()
	
#endregion


#region Implementation functions

func type() -> Type:
	return Type.none

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	return Type.none

func deactivateImpl() -> void:
	pass

func exit() -> StringName:
	return BasicState.TYPE_NONE

#endregion
