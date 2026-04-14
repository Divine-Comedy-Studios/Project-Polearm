extends MeshInstance3D

signal valueChanged(new_value: float)
signal maxValueChanged(new_max: float)

var max_value := 1000.0
var current_value := 1000.0

func _ready() -> void:
	# Make sure the UI can find us
	add_to_group("Player")
	
	# Tell the UI what the starting numbers are
	maxValueChanged.emit(max_value)
	valueChanged.emit(current_value)

func _input(event: InputEvent) -> void:
	# Check if Space was just pressed
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_SPACE):
		take_damage(50.0)

func take_damage(amount: float) -> void:
	# Subtract the amount and ensure we don't go below 0
	current_value = clamp(current_value - amount, 0, max_value)
	
	# Tell the ValueBarUI the value changed!
	valueChanged.emit(current_value)
	
	print("Current Value: ", current_value)
