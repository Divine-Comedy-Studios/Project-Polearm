extends CenterContainer

#region Button Path Variables

@onready var forward : ActionMappingButton = $"HBoxContainer/Left Colon/Forward"
@onready var backward : ActionMappingButton = $"HBoxContainer/Left Colon/Backward"
@onready var jump : ActionMappingButton = $"HBoxContainer/Left Colon/Jump"
@onready var switchWeapon : ActionMappingButton = $"HBoxContainer/Left Colon/SwitchWeapon"
@onready var targetLeft : ActionMappingButton = $"HBoxContainer/Left Colon/TargetLeft"
@onready var targetRight : ActionMappingButton = $"HBoxContainer/Left Colon/TargetRight"
@onready var lightAttack : ActionMappingButton = $"HBoxContainer/Left Colon/LightAttack"
@onready var heavyAttack : ActionMappingButton = $"HBoxContainer/Left Colon/HeavyAttack"

@onready var left : ActionMappingButton = $"HBoxContainer/Right Colon/Left"
@onready var right : ActionMappingButton = $"HBoxContainer/Right Colon/Right"
@onready var dodge : ActionMappingButton = $"HBoxContainer/Right Colon/Dodge"
@onready var sprint : ActionMappingButton = $"HBoxContainer/Right Colon/Sprint"
@onready var shoot : ActionMappingButton = $"HBoxContainer/Right Colon/Shoot"
@onready var launcher : ActionMappingButton = $"HBoxContainer/Right Colon/Launcher"
@onready var target : ActionMappingButton = $"HBoxContainer/Right Colon/Target"
@onready var taunt : ActionMappingButton = $"HBoxContainer/Right Colon/Taunt"

#endregion 

const KEY_ICONS : Dictionary = {
	# --- Letters ---
	KEY_A: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_a.png"),
	KEY_B: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_b.png"),
	KEY_C: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_c.png"),
	KEY_D: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_d.png"),
	KEY_E: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_e.png"),
	KEY_F: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f.png"),
	KEY_G: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_g.png"),
	KEY_H: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_h.png"),
	KEY_I: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_i.png"),
	KEY_J: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_j.png"),
	KEY_K: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_k.png"),
	KEY_L: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_l.png"),
	KEY_M: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_m.png"),
	KEY_N: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_n.png"),
	KEY_O: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_o.png"),
	KEY_P: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_p.png"),
	KEY_Q: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_q.png"),
	KEY_R: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_r.png"),
	KEY_S: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_s.png"),
	KEY_T: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_t.png"),
	KEY_U: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_u.png"),
	KEY_V: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_v.png"),
	KEY_W: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_w.png"),
	KEY_X: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_x.png"),
	KEY_Y: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_y.png"),
	KEY_Z: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_z.png"),

	# --- Numbers ---
	KEY_0: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_0.png"),
	KEY_1: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_1.png"),
	KEY_2: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_2.png"),
	KEY_3: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_3.png"),
	KEY_4: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_4.png"),
	KEY_5: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_5.png"),
	KEY_6: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_6.png"),
	KEY_7: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_7.png"),
	KEY_8: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_8.png"),
	KEY_9: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_9.png"),

	# --- Special Keys ---
	KEY_SPACE: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_space.png"),
	KEY_SHIFT: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_shift.png"),
	KEY_CTRL: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_ctrl.png"),
	KEY_ALT: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_alt.png"),
	KEY_TAB: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_tab.png"),
	KEY_CAPSLOCK: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_capslock.png"),
	KEY_ESCAPE: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_escape.png"),
	KEY_ENTER: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_enter.png"),
	KEY_BACKSPACE: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_backspace.png"),

	# --- Arrow Keys ---
	KEY_UP: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_arrow_up.png"),
	KEY_DOWN: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_arrow_down.png"),
	KEY_LEFT: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_arrow_left.png"),
	KEY_RIGHT: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_arrow_right.png"),

	# --- Function Keys ---
	KEY_F1: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f1.png"),
	KEY_F2: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f2.png"),
	KEY_F3: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f3.png"),
	KEY_F4: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f4.png"),
	KEY_F5: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f5.png"),
	KEY_F6: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f6.png"),
	KEY_F7: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f7.png"),
	KEY_F8: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f8.png"),
	KEY_F9: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f9.png"),
	KEY_F10: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f10.png"),
	KEY_F11: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f11.png"),
	KEY_F12: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f12.png"),

	# --- Mouse ---
	MOUSE_BUTTON_LEFT: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/mouse_left.png"),
	MOUSE_BUTTON_RIGHT: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/mouse_right.png"),
	MOUSE_BUTTON_MIDDLE: preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/mouse_middle.png"),
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
		"Move left": left,
		"Move right": right,
		"Move forwards": forward,
		"Move backwards": backward,
		"Taunt": taunt,
		"Switch weapon": switchWeapon # Added this as it's in your @onready but not in default keyboard settings
	}

	# Apply the Images
	for action in SettingsManager.Settings["keyboard"]:
		if buttonMap.has(action):
			var button = buttonMap[action]
			var keyCode = SettingsManager.Settings["keyboard"][action]
			button.setBinding(KEY_ICONS.get(keyCode, null))
			button.remapped.connect(_on_remapped.bind(action, button))

func _on_remapped(keyCode: int, inputType: ActionMappingButton.InputDic, direction: int, action: String, button: ActionMappingButton) -> void:
	var icon = KEY_ICONS.get(keyCode, null)

	for otherAction in SettingsManager.Settings["keyboard"]:
		if otherAction == action:
			continue
		if SettingsManager.Settings["keyboard"][otherAction] == keyCode:
			var oldKeyCode = SettingsManager.Settings["keyboard"][action]
			SettingsManager.Settings["keyboard"][otherAction] = oldKeyCode
			if buttonMap.has(otherAction):
				buttonMap[otherAction].setBinding(KEY_ICONS.get(oldKeyCode, null))
			break

	SettingsManager.Settings["keyboard"][action] = keyCode
	button.setBinding(icon)
	SettingsManager.saveSettings()
