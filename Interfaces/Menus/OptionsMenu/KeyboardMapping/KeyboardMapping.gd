extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Scene members

@onready var _buttonContainer := $"CenterContainer/HBoxContainer"

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
	return Type.keyboardOptions

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel and _remapping:
		return BACK_MENU

	return Type.none

#endregion


#region Private funcions

func _findAndInitButton(node : Node) -> void:
	if node is ActionMappingButton:
		_buttonMap[node.ACTION_NAME] = node as ActionMappingButton # Insert into dictionary

		var keyCode := SettingsManager.Settings["keyboard"][node.ACTION_NAME]
		node.setBindingIcon(KEY_ICONS.get(keyCode, null))

		node.remapped.connect(_on_remapped)
		node.listening.connect(_on_button_listening)
	else:
		for child : Node in node.get_children():
			_findAndInitButton(node)

#endregion


#region Signal functions

func _on_remapped(
	keyCode : int,
	action : String
) -> void:
	for otherAction in SettingsManager.Settings["keyboard"]: # Swap keys with action assigned to the same input
		if otherAction == action:
			continue

		if SettingsManager.Settings["keyboard"][otherAction] == keyCode:
			var oldKeyCode := SettingsManager.Settings["keyboard"][action]
			SettingsManager.Settings["keyboard"][otherAction] = oldKeyCode

			break


func _on_button_listening(listening : bool) -> void:
	_remapping = listening

#endregion
