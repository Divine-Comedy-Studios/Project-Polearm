extends CenterContainer


#region Scene members

@onready var jump := $"HBoxContainer/Left Colon/Jump" as ActionMappingButton
@onready var switchWeapon := $"HBoxContainer/Left Colon/SwitchWeapon" as ActionMappingButton
@onready var targetLeft := $"HBoxContainer/Left Colon/TargetLeft" as ActionMappingButton
@onready var targetRight := $"HBoxContainer/Left Colon/TargetRight" as ActionMappingButton
@onready var lightAttack := $"HBoxContainer/Left Colon/LightAttack" as ActionMappingButton
@onready var heavyAttack := $"HBoxContainer/Left Colon/HeavyAttack" as ActionMappingButton

@onready var dodge := $"HBoxContainer/Right Colon/Dodge" as ActionMappingButton
@onready var sprint := $"HBoxContainer/Right Colon/Sprint" as ActionMappingButton
@onready var shoot := $"HBoxContainer/Right Colon/Shoot" as ActionMappingButton
@onready var launcher := $"HBoxContainer/Right Colon/Launcher" as ActionMappingButton
@onready var target := $"HBoxContainer/Right Colon/Target" as ActionMappingButton
@onready var taunt := $"HBoxContainer/Right Colon/Taunt" as ActionMappingButton

#endregion 


#region Constants

const JOY_BUTTON_ICONS : Dictionary[JoyButton, Texture2D] = {
	JoyButton.JOY_BUTTON_A : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_a.png"),
	JoyButton.JOY_BUTTON_B : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_b.png"),
	JoyButton.JOY_BUTTON_X : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_x.png"),
	JoyButton.JOY_BUTTON_Y : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_y.png"),
	JoyButton.JOY_BUTTON_BACK : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_back.png"),
	JoyButton.JOY_BUTTON_START : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_start.png"),
	JoyButton.JOY_BUTTON_LEFT_SHOULDER : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_lb.png"),
	JoyButton.JOY_BUTTON_RIGHT_SHOULDER : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_rb.png"),
	JoyButton.JOY_BUTTON_LEFT_STICK : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_ls.png"),
	JoyButton.JOY_BUTTON_RIGHT_STICK : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_rs.png"),
	JoyButton.JOY_BUTTON_DPAD_UP : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_dpad_up.png"),
	JoyButton.JOY_BUTTON_DPAD_DOWN : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_dpad_down.png"),
	JoyButton.JOY_BUTTON_DPAD_LEFT : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_dpad_left.png"),
	JoyButton.JOY_BUTTON_DPAD_RIGHT : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_dpad_right.png"),
}

const JOY_AXIS_ICONS : Dictionary[JoyAxis, Dictionary] = {
	JoyAxis.JOY_AXIS_LEFT_X : {
		"neg" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_l_left.png"), 
		"pos" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_l_right.png")
	},
	JoyAxis.JOY_AXIS_LEFT_Y : {
		"neg" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_l_up.png"), 
		"pos" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_l_down.png")
	},
	JoyAxis.JOY_AXIS_RIGHT_X : {
		"neg" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_r_left.png"), 
		"pos" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_r_right.png")
	},
	JoyAxis.JOY_AXIS_RIGHT_Y : {
		"neg" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_r_up.png"), 
		"pos" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_r_down.png")
	},
	JoyAxis.JOY_AXIS_TRIGGER_LEFT : {
		"pos" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_lt.png")
	},
	JoyAxis.JOY_AXIS_TRIGGER_RIGHT : {
		"pos" : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_rt.png")
	},
}

#endregion


#region Member variables

@onready var _buttonMap : Dictionary[StringName, ActionMappingButton] = { 	
	&"Light attack" : lightAttack,
	&"Heavy attack" : heavyAttack,
	&"Jump" : jump,
	&"Shoot" : shoot,
	&"Target left" : targetLeft,
	&"Target right" : targetRight,
	&"Dodge" : dodge,
	&"Sprint" : sprint,
	&"Launcher" : launcher,
	&"Held target toggle" : target,
	&"Taunt" : taunt,
	&"Switch weapon" : switchWeapon
}

#endregion


#region Built-in functions

func _ready() -> void:
	# Apply the Images
	for action in SettingsManager.Settings["controller"]:
		if _buttonMap.has(action):
			var button := _buttonMap[action]
			var binding := SettingsManager.Settings["controller"][action] as Dictionary
			var isAxis := (binding["type"] == "axis") as bool
			var icon := _getJoyIcon(binding["id"], binding.get("direction", 0), isAxis)
			button.setBinding(icon)
			button.remapped.connect(_on_remapped.bind(action, button))

#endregion


#region Private functions

func _getJoyIcon(
	id : int, 
	direction : int, 
	isAxis : bool
) -> Texture2D:
	if isAxis:
		if not JOY_AXIS_ICONS.has(id):
			return null
		var key = "pos" if direction >= 0 else "neg"
		return JOY_AXIS_ICONS[id].get(key, null)
	else:
		return JOY_BUTTON_ICONS.get(id, null)

#endregion


#region Signal functions

func _on_remapped(
	keyCode : int, 
	inputType : ActionMappingButton.InputDic, 
	direction : int, 
	action : String, 
	button : ActionMappingButton
) -> void:
	var newBinding : Dictionary = { }

	if direction != 0:
		newBinding = {
			"type" : "axis", 
			"id" : keyCode, 
			"direction" : direction
		}
	else:
		newBinding = {
			"type" : "button",
			"id" : keyCode
		}

	var icon = _getJoyIcon(keyCode, direction, direction != 0)

	# Duplicate check
	for otherAction in SettingsManager.Settings["controller"]:
		if otherAction == action:
			continue

		var otherBinding = SettingsManager.Settings["controller"][otherAction]
		if otherBinding["id"] == keyCode and otherBinding.get("direction", 0) == direction:
			var oldBinding = SettingsManager.Settings["controller"][action]
			SettingsManager.Settings["controller"][otherAction] = oldBinding
			
			if _buttonMap.has(otherAction):
				var oldIcon = _getJoyIcon(oldBinding["id"], oldBinding.get("direction", 0), oldBinding["type"] == "axis")
				_buttonMap[otherAction].setBinding(oldIcon)

			break

	button.setBinding(icon)

	SettingsManager.Settings["controller"][action] = newBinding
	SettingsManager.saveSettings()

#endregion
