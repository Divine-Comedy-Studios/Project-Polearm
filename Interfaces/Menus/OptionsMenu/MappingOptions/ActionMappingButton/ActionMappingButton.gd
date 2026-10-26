extends Button
class_name ActionMappingButton


#region Constants

const KEY_ICONS : Dictionary[int, Texture2D] = {
	# Letters
	Key.KEY_A : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_a.png"),
	Key.KEY_B : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_b.png"),
	Key.KEY_C : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_c.png"),
	Key.KEY_D : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_d.png"),
	Key.KEY_E : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_e.png"),
	Key.KEY_F : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f.png"),
	Key.KEY_G : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_g.png"),
	Key.KEY_H : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_h.png"),
	Key.KEY_I : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_i.png"),
	Key.KEY_J : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_j.png"),
	Key.KEY_K : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_k.png"),
	Key.KEY_L : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_l.png"),
	Key.KEY_M : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_m.png"),
	Key.KEY_N : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_n.png"),
	Key.KEY_O : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_o.png"),
	Key.KEY_P : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_p.png"),
	Key.KEY_Q : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_q.png"),
	Key.KEY_R : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_r.png"),
	Key.KEY_S : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_s.png"),
	Key.KEY_T : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_t.png"),
	Key.KEY_U : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_u.png"),
	Key.KEY_V : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_v.png"),
	Key.KEY_W : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_w.png"),
	Key.KEY_X : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_x.png"),
	Key.KEY_Y : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_y.png"),
	Key.KEY_Z : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_z.png"),

	# Numbers
	Key.KEY_0 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_0.png"),
	Key.KEY_1 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_1.png"),
	Key.KEY_2 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_2.png"),
	Key.KEY_3 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_3.png"),
	Key.KEY_4 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_4.png"),
	Key.KEY_5 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_5.png"),
	Key.KEY_6 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_6.png"),
	Key.KEY_7 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_7.png"),
	Key.KEY_8 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_8.png"),
	Key.KEY_9 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_9.png"),

	# Special keys
	Key.KEY_SPACE : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_space.png"),
	Key.KEY_SHIFT : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_shift.png"),
	Key.KEY_CTRL : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_ctrl.png"),
	Key.KEY_ALT : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_alt.png"),
	Key.KEY_TAB : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_tab.png"),
	Key.KEY_CAPSLOCK : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_capslock.png"),
	Key.KEY_ESCAPE : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_escape.png"),
	Key.KEY_ENTER : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_enter.png"),
	Key.KEY_BACKSPACE : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_backspace.png"),

	# Arrow keys
	Key.KEY_UP : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_arrow_up.png"),
	Key.KEY_DOWN : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_arrow_down.png"),
	Key.KEY_LEFT : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_arrow_left.png"),
	Key.KEY_RIGHT : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_arrow_right.png"),

	# Function keys
	Key.KEY_F1 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f1.png"),
	Key.KEY_F2 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f2.png"),
	Key.KEY_F3 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f3.png"),
	Key.KEY_F4 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f4.png"),
	Key.KEY_F5 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f5.png"),
	Key.KEY_F6 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f6.png"),
	Key.KEY_F7 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f7.png"),
	Key.KEY_F8 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f8.png"),
	Key.KEY_F9 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f9.png"),
	Key.KEY_F10 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f10.png"),
	Key.KEY_F11 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f11.png"),
	Key.KEY_F12 : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/keyboard_f12.png"),
}


const MOUSE_ICONS : Dictionary[int, Texture2D] = {
	MouseButton.MOUSE_BUTTON_LEFT : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/mouse_left.png"),
	MouseButton.MOUSE_BUTTON_RIGHT : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/mouse_right.png"),
	MouseButton.MOUSE_BUTTON_MIDDLE : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/mouse_middle.png"),
}


const CONTROLLER_BUTTON_ICONS : Dictionary[int, Texture2D] = {
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


const CONTROLLER_AXIS_ICONS : Dictionary[int, Texture2D] = {
	JoyAxis.JOY_AXIS_TRIGGER_LEFT : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_lt.png"),
	JoyAxis.JOY_AXIS_TRIGGER_RIGHT : preload("res://Assets/Interfaces/ButtonSymbols/Xbox Series/Default/xbox_rt.png"),
}

#endregion


#region Signals

signal listening(value : bool)

#endregion


#region Scene members

@export_group("Scene members")
@export var _label : Label = null
@export var _icon : TextureRect = null

#endregion


#region Exported variables

@export_group("Remap config")
@export var ACTION_NAME : StringName = StringName()
@export var INPUT_MODE : SettingsManager.InputType = SettingsManager.InputType.keyboard

@export_group("Button config")
@export var LABLE_TEXT : String:
	set(value):
		_label.text = value
@export var ICON_TEXTURE : Texture2D:
	set(value):
		_icon.texture = value

#endregion


#region Member variables

var _listening : bool = false

#endregion


#region Built-in functions

func _ready() -> void:
	mouse_entered.connect(_mouseEntered)
	pressed.connect(_buttonPressed)

	flat = true

	_updateTexture()


func _input(event : InputEvent) -> void:
	if not _listening or not event.is_pressed():
		return

	match INPUT_MODE:
		SettingsManager.InputType.keyboard:
			_checkKeyboardMouseInput(event)
		SettingsManager.InputType.controller:
			_checkControllerInput(event)


func _process(_delta: float) -> void:
	listening.emit(_listening)

	_updateTexture()

#endregion


#region Private functions

# Texture updates

func _updateTexture() -> void:
	var inputData := Globals.settingsManager.getVariant(_getSectionName(), ACTION_NAME) as Dictionary
	match (inputData["type"] as SettingsManager.InputType):
		SettingsManager.InputType.keyboard:
			_icon.texture = KEY_ICONS[inputData["id"] as int]
		SettingsManager.InputType.mouse:
			_icon.texture = MOUSE_ICONS[inputData["id"] as int]
		SettingsManager.InputType.controllerButton:
			_icon.texture = CONTROLLER_BUTTON_ICONS[inputData["id"] as int]
		SettingsManager.InputType.controllerAxis:
			_icon.texture = CONTROLLER_AXIS_ICONS[inputData["id"] as int]


# Input capture & button presses

func _mouseEntered() -> void:
	# If the mouse touches the button, grabs focus
	if not has_focus():
		grab_focus()

func _buttonPressed() -> void:
	_listening = true
	_icon.texture = null
	set_process_input(true)

func _eventHandled() -> void:
	_listening = false
	get_viewport().set_input_as_handled()
	set_process_input(false)


# Input mapping implementation

func _checkKeyboardMouseInput(event : InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == Key.KEY_ESCAPE:
			_eventHandled()
			return

		_eventHandled()
		_remap("keyboard", SettingsManager.InputType.keyboard, KEY_ICONS, event.keycode)
	elif event is InputEventMouseButton:
		_eventHandled()
		_remap("keyboard", SettingsManager.InputType.mouse, MOUSE_ICONS, event.button_index)

func _checkControllerInput(event : InputEvent) -> void:
	if event is InputEventJoypadButton:
		_eventHandled()
		_remap("controller", SettingsManager.InputType.controllerButton, CONTROLLER_BUTTON_ICONS, event.button_index)
	elif event is InputEventJoypadMotion:
		if event.axis == JoyAxis.JOY_AXIS_TRIGGER_LEFT or event.axis == JoyAxis.JOY_AXIS_TRIGGER_RIGHT:
			_eventHandled()
			_remap("controller", SettingsManager.InputType.controllerAxis, CONTROLLER_AXIS_ICONS, event.axis)


func _remap(section : String, type : SettingsManager.InputType, iconTex : Dictionary[int, Texture2D], code : int) -> void:
	_icon.texture = iconTex[code]
	
	var data : Dictionary[String, int] = {
		"type" : type,
		"id" : code,
	}

	# Swap keys with action assigned to the same input
	var oldAction := Globals.settingsManager.getVariant(section, ACTION_NAME) as Dictionary
	for otherActionName in Globals.settingsManager.getSettingNames(section):
		if otherActionName == ACTION_NAME:
			continue
		
		var rawInputData = Globals.settingsManager.getVariant(section, otherActionName)
		if not rawInputData is Dictionary:
			continue

		var inputData := rawInputData as Dictionary
		if (inputData["type"] as int) == data["type"] and (inputData["id"] as int) == data["id"]:
			Globals.settingsManager.setVariant(section, otherActionName, oldAction)

			break

	# Set settings
	Globals.settingsManager.setVariant(section, ACTION_NAME, data)
	Globals.settingsManager.saveSettings()
	Globals.settingsManager.applyInputSettings(_getSectionName())

# Utility

func _getSectionName() -> String:
	return "keyboard" if INPUT_MODE == SettingsManager.InputType.keyboard else "controller"

#endregion
