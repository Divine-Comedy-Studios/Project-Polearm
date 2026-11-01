extends InterfaceState


#region Export variables

@export_group("Key mapping config")
@export_enum("keyboard", "controller") var MAPPING_TYPE : String = "keyboard"

@export_group("State machine config")
@export var TYPE : Type = Type.none
@export var BACK_MENU : Type = Type.none

#endregion


#region Member variables

var _onBackPressed : bool = false

var _remapping : bool = false

#endregion


#region Override functions

func type() -> Type:
	return TYPE

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel and not _remapping:
		return BACK_MENU
	
	if _onBackPressed and not _remapping:
		return BACK_MENU
		
	return Type.none


func _deactivateImpl() -> void:
	_onBackPressed = false

#endregion


#region Signal functions

func _onButtonListening(listening : bool) -> void:
	_remapping = listening


func _onResetPressed() -> void:
	Globals.settingsManager.saveSectionDefault(MAPPING_TYPE)

func _on_back_pressed() -> void:
	_onBackPressed = true

#endregion
