class_name ActionMappingButton extends Button

signal remapped(keyCode: int, inputType: InputDic, direction: int)  # ADD THIS


enum InputDic { Keyboard, Controller }

@onready var label : Label = $"HBoxContainer/Label"
@onready var symbol : TextureRect = $"HBoxContainer/Symbol"

@export var LABLE_TEXT : String = "Replace this"
@export var SYMBOL_ICON : Texture2D
@export var INPUT_MODE : InputDic

var listening: bool = false
var awaitingEscRelease: bool = false

func _ready() -> void:
	mouse_entered.connect(mouseEntered)
	pressed.connect(buttonPressed)

	flat = true

	label.text = LABLE_TEXT

	if SYMBOL_ICON != null:
		symbol.texture = SYMBOL_ICON

func mouseEntered() -> void:
	# If the mouse touches the button, grabs focus
	if not has_focus():
		grab_focus()

func buttonPressed() -> void:
	listening = true
	symbol.texture = null
	SettingsManager.isRemapping = true
	print(SettingsManager.isRemapping)
	set_process_input(true)

func setBinding(icon: Texture2D) -> void:
	if icon != null:
		symbol.texture = icon
	else:
		symbol.texture = null

func _input(event: InputEvent) -> void:
	if not listening and not awaitingEscRelease:
		return
		
	if event is InputEventKey:
		if INPUT_MODE != InputDic.Keyboard:
			return
		get_viewport().set_input_as_handled()
		
		if event.keycode == KEY_ESCAPE:
			if event.pressed:
				listening = false
				awaitingEscRelease = true
				print("hey")
			else:
				awaitingEscRelease = false
				SettingsManager.isRemapping = false
				set_process_input(false)
				print("hoe")
			return

		if event.pressed and listening:
			print("Key pressed: ", event.keycode)
			listening = false
			SettingsManager.isRemapping = false
			set_process_input(false)
			emit_signal("remapped", event.keycode, InputDic.Keyboard, 0)

	elif event is InputEventMouseButton and event.pressed and listening:
		if INPUT_MODE != InputDic.Keyboard:
			return
		get_viewport().set_input_as_handled()
		print("Mouse button pressed: ", event.button_index)
		listening = false
		SettingsManager.isRemapping = false
		set_process_input(false)
		emit_signal("remapped", event.button_index, InputDic.Keyboard, 0)

	elif event is InputEventJoypadButton and event.pressed and listening:
		if INPUT_MODE != InputDic.Controller:
			return
		get_viewport().set_input_as_handled()
		print("Controller button pressed: ", event.button_index)
		listening = false
		SettingsManager.isRemapping = false
		set_process_input(false)
		emit_signal("remapped", event.button_index, InputDic.Controller, 0)
	
	elif event is InputEventJoypadMotion and listening:
		if INPUT_MODE != InputDic.Controller:
			return
		if abs(event.axis_value) > 0.5:
			get_viewport().set_input_as_handled()

			var axisID = event.axis
			var direction = sign(event.axis_value)

			print("Joypad Axis: ", axisID, " Direction: ", direction)

			listening = false
			SettingsManager.isRemapping = false
			set_process_input(false)

			emit_signal("remapped", axisID, InputDic.Controller, direction)
