extends Button
class_name ActionMappingButton


#region Enums

enum InputType {
	keyboard,
	controller,
	
	# These are only used for utility and should not be set by INPUT_TYPE
	axis,
}

#endregion


#region Signals

signal remapped(keyCode : int, actionName : StringName)  # ADD THIS
signal listening(value : bool)

#endregion


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

	# Mouse
	MouseButton.MOUSE_BUTTON_LEFT : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/mouse_left.png"),
	MouseButton.MOUSE_BUTTON_RIGHT : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/mouse_right.png"),
	MouseButton.MOUSE_BUTTON_MIDDLE : preload("res://Assets/Interfaces/ButtonSymbols/Keyboard & Mouse/mouse_middle.png"),
}

#endregion


#region Export variables

@export var LABLE_TEXT : String = "Replace this"
@export var SYMBOL_ICON : Texture2D = null
@export var INPUT_TYPE : InputType = InputType.keyboard
@export var ACTION_NAME : StringName = StringName()

#endregion


#region Export scene members

@onready var _label : Label = $"HBoxContainer/Label"
@onready var _symbol : TextureRect = $"HBoxContainer/Symbol"

#endregion


#region Member variables

var _listening : bool = false:
	set(value):
		listening.emit(value)
		_listening = value

#endregion


#region Built-in functions

func _ready() -> void:
	mouse_entered.connect(_mouseEntered)
	pressed.connect(_buttonPressed)

	flat = true

	_label.text = LABLE_TEXT

	if SYMBOL_ICON != null:
		_symbol.texture = SYMBOL_ICON

#endregion


#region Built-in functions

func _input(event : InputEvent) -> void:
	if not _listening or not event.is_pressed():
		return

	if INPUT_TYPE == InputType.keyboard:
		_checkKeyboardMouseInput(event)
	elif INPUT_TYPE == InputType.controller:
		_checkControllerInput(event)

#endregion


#region Public functions

func updateTexture(inputType : InputType, code : int) -> void:
	if inputType == InputType.keyboard:
		_symbol.texture = KEY_ICONS[code]
	elif inputType == InputType.controller:
		_symbol.texture = CONTROLLER_ICONS[code]

#endregion


#region Private functions

# Input capture & button presses

func _mouseEntered() -> void:
	# If the mouse touches the button, grabs focus
	if not has_focus():
		grab_focus()

func _buttonPressed() -> void:
	_listening = true
	_symbol.texture = null
	set_process_input(true)

func _eventHandled() -> void:
	_listening = false
	get_viewport().set_input_as_handled()
	set_process_input(false)


func _remap(code : int) -> void:
	remapped.emit(code, ACTION_NAME)

	var settingsCategory : String = String()

	if INPUT_TYPE == InputType.keyboard:
		settingsCategory = "keyboard"
		_symbol.texture = KEY_ICONS[code]
	elif INPUT_TYPE == InputType.controller:
		settingsCategory = "controller"
		_symbol.texture = CONTROLLER_ICONS[code]

	SettingsManager.Settings[settingsCategory][ACTION_NAME] = keyCode
	SettingsManager.saveSettings()


# Input mapping implementation

func _checkKeyboardMouseInput(event : InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == Key.KEY_ESCAPE:
			_eventHandled()
			return

		_eventHandled()
		_remap(event.keycode)
	elif event is InputEventMouseButton:
		_eventHandled()
		_remap(event.button_index)


func _checkControllerInput(event : InputEvent) -> void:
	if event is InputEventJoypadButton:
		_eventHandled()
		_remap(event.button_index)

#endregion
