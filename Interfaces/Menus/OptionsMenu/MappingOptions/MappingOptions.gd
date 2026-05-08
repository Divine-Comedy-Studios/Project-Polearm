extends InterfaceState


#region Export variables

@export_group("Key mapping config")
@export_enum("keyboard", "controller") var MAPPING_TYPE : String = "keyboard"

@export_group("State machine config")
@export var TYPE : Type = Type.none
@export var BACK_MENU : Type = Type.none

#endregion


#region Scene members

@export_group("Scene members")
@export var _buttonContainer : Node = null

#endregion


#region Member variables

@onready var _buttonMap : Dictionary[StringName, ActionMappingButton] = { }

var _remapping : bool = false

#endregion


#region Built-in functions

func _ready() -> void:
	_findAndInitButton(_buttonContainer)

#endregion


#region Override functions

func type() -> Type:
	return TYPE

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel and not _remapping:
		return BACK_MENU

	return Type.none

#endregion


#region Private funcions

func _findAndInitButton(node : Node) -> void:
	if node is ActionMappingButton:
		_buttonMap[node.ACTION_NAME] = node as ActionMappingButton # Insert into dictionary

		node.remapped.connect(_onRemapped)
		node.listening.connect(_onButtonListening)
	else:
		for child : Node in node.get_children():
			_findAndInitButton(child)

#endregion


#region Signal functions

func _onRemapped(actionName : StringName, newAction : Dictionary[String, int], oldAction : Dictionary) -> void:
	for otherActionName in SettingsManager.getSettingNames(MAPPING_TYPE): # Swap keys with action assigned to the same input
		if otherActionName == actionName:
			continue

		var inputData := SettingsManager.getVariant(MAPPING_TYPE, otherActionName) as Dictionary
		if inputData["type"] as int == newAction["type"] and inputData["id"] as int == newAction["id"]:
			SettingsManager.setVariant(MAPPING_TYPE, otherActionName, oldAction)

			break


func _onButtonListening(listening : bool) -> void:
	_remapping = listening

#endregion
