extends CenterContainer

#region Button Path Variables

@onready var jump : ActionMappingButton = $"HBoxContainer/Left Colon/Jump"
@onready var switchWeapon : ActionMappingButton = $"HBoxContainer/Left Colon/SwitchWeapon"
@onready var targetLeft : ActionMappingButton = $"HBoxContainer/Left Colon/TargetLeft"
@onready var targetRight : ActionMappingButton = $"HBoxContainer/Left Colon/TargetRight"
@onready var lightAttack : ActionMappingButton = $"HBoxContainer/Left Colon/LightAttack"
@onready var heavyAttack : ActionMappingButton = $"HBoxContainer/Left Colon/HeavyAttack"

@onready var dodge : ActionMappingButton = $"HBoxContainer/Right Colon/Dodge"
@onready var sprint : ActionMappingButton = $"HBoxContainer/Right Colon/Sprint"
@onready var shoot : ActionMappingButton = $"HBoxContainer/Right Colon/Shoot"
@onready var launcher : ActionMappingButton = $"HBoxContainer/Right Colon/Launcher"
@onready var target : ActionMappingButton = $"HBoxContainer/Right Colon/Target"
@onready var taunt : ActionMappingButton = $"HBoxContainer/Right Colon/Taunt"

#endregion 

const JOY_BUTTON_ICONS : Dictionary = {
	JOY_BUTTON_A: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_a.png"),
	JOY_BUTTON_B: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_b.png"),
	JOY_BUTTON_X: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_x.png"),
	JOY_BUTTON_Y: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_y.png"),
	JOY_BUTTON_BACK: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_back.png"),
	JOY_BUTTON_START: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_button_start.png"),
	JOY_BUTTON_LEFT_SHOULDER: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_lb.png"),
	JOY_BUTTON_RIGHT_SHOULDER: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_rb.png"),
	JOY_BUTTON_LEFT_STICK: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_ls.png"),
	JOY_BUTTON_RIGHT_STICK: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_rs.png"),
	JOY_BUTTON_DPAD_UP: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_dpad_up.png"),
	JOY_BUTTON_DPAD_DOWN: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_dpad_down.png"),
	JOY_BUTTON_DPAD_LEFT: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_dpad_left.png"),
	JOY_BUTTON_DPAD_RIGHT: preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_dpad_right.png"),
}

const JOY_AXIS_ICONS : Dictionary = {
	JOY_AXIS_LEFT_X: {"neg": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_l_left.png"), "pos": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_l_right.png")},
	JOY_AXIS_LEFT_Y: {"neg": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_l_up.png"), "pos": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_l_down.png")},
	JOY_AXIS_RIGHT_X: {"neg": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_r_left.png"), "pos": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_r_right.png")},
	JOY_AXIS_RIGHT_Y: {"neg": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_r_up.png"), "pos": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_stick_r_down.png")},
	JOY_AXIS_TRIGGER_LEFT: {"pos": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_lt.png")},
	JOY_AXIS_TRIGGER_RIGHT: {"pos": preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_rt.png")},
}

var buttonMap : Dictionary = { }
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	buttonMap = {
		"Light attack": lightAttack,
		"Heavy attack": heavyAttack,
		"Jump": jump,
		"Shoot": shoot,
		"Target left": targetLeft,
		"Target right": targetRight,
		"Dodge": dodge,
		"Sprint": sprint,
		"Launcher": launcher,
		"Held target toggle": target,
		"Taunt": taunt,
		"Switch weapon": switchWeapon
	}

	# Apply the Images
	for action in SettingsManager.Settings["controller"]:
		if buttonMap.has(action):
			var button = buttonMap[action]
			var binding = SettingsManager.Settings["controller"][action]
			var isAxis = binding["type"] == "axis"
			var icon = getJoyIcon(binding["id"], binding.get("direction", 0), isAxis)
			button.setBinding(icon)
			button.remapped.connect(_on_remapped.bind(action, button))

func _on_remapped(keyCode: int, inputType: ActionMappingButton.InputDic, direction: int, action: String, button: ActionMappingButton) -> void:
	var newBinding : Dictionary
	if direction != 0:
		newBinding = {"type": "axis", "id": keyCode, "direction": direction}
	else:
		newBinding = {"type": "button", "id": keyCode}

	var icon = getJoyIcon(keyCode, direction, direction != 0)

	# Duplicate check
	for otherAction in SettingsManager.Settings["controller"]:
		if otherAction == action:
			continue
		var otherBinding = SettingsManager.Settings["controller"][otherAction]
		if otherBinding["id"] == keyCode and otherBinding.get("direction", 0) == direction:
			var oldBinding = SettingsManager.Settings["controller"][action]
			SettingsManager.Settings["controller"][otherAction] = oldBinding
			if buttonMap.has(otherAction):
				var oldIcon = getJoyIcon(oldBinding["id"], oldBinding.get("direction", 0), oldBinding["type"] == "axis")
				buttonMap[otherAction].setBinding(oldIcon)
			break

	SettingsManager.Settings["controller"][action] = newBinding
	button.setBinding(icon)
	SettingsManager.saveSettings()

func getJoyIcon(id: int, direction: int, isAxis: bool) -> Texture2D:
	if isAxis:
		if not JOY_AXIS_ICONS.has(id):
			return null
		var key = "pos" if direction >= 0 else "neg"
		return JOY_AXIS_ICONS[id].get(key, null)
	else:
		return JOY_BUTTON_ICONS.get(id, null)
