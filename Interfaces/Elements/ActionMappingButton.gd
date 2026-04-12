class_name ActionMappingButton extends Button

@onready var label : Label = $"HBoxContainer/Label"
@onready var symbol : TextureRect = $"HBoxContainer/Symbol"

@export var labelText : String = "Replace this"
@export var symbolIcon : Texture2D

func _ready() -> void:
	mouse_entered.connect(mouseEntered)
	pressed.connect(buttonPressed)

	flat = true

	label.text = labelText

	if symbolIcon != null:
		symbol.texture = symbolIcon

func mouseEntered() -> void:
	# If the mouse touches the button, grabs focus
	if not has_focus():
		grab_focus()

func buttonPressed() -> void:
	pass
