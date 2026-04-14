class_name ValueBarUI extends CanvasLayer

#region Exported Variables

@export_group("Connection Settings")
@export var GROUP_NAME : StringName
@export var GROUP_INDEX : int
@export var SIGNAL_NAME : StringName = &"valueChanged"
@export var MAX_VALUE_SIGNAL : StringName = &"maxValueChanged"

@export_group("Value Setting")

@export_group("Visual Transform Settings")
@export var SIZE := Vector2(200, 15)
@export var POS := Vector2(20, 20)
@export var VALUE_TEXTURE : Texture2D
@export var CHANGE_TEXTURE : Texture2D
@export var BACKGROUND_TEXTURE : Texture2D
@export var PROGRESS_GRADIENT : Gradient
@export var CHANGE_COLOR := Color8(255,255,255)


#endregion 

#region Node Variables

@onready var panel : Panel = $"Panel"
@onready var timer : Timer = $"Timer"
@onready var changeBar : TextureProgressBar = $"Panel/ChangeBar"
@onready var valueBar : TextureProgressBar = $"Panel/ValueBar"

#endregion

func _ready() -> void:

	# Connection Initialization
	var nodes = get_tree().get_nodes_in_group(GROUP_NAME)

	assert(nodes.size() > GROUP_INDEX, "ValueBar Error: No node found in group %s at index %d" % [GROUP_NAME, GROUP_INDEX])

	var targetNode = nodes[GROUP_INDEX]

	if targetNode.has_signal(SIGNAL_NAME):
		targetNode.connect(SIGNAL_NAME, _onValueChanged)
	else:
		assert(false, "ValueBar Error: Target node missing signal: " + SIGNAL_NAME)

	if targetNode.has_signal(MAX_VALUE_SIGNAL):
		targetNode.connect(MAX_VALUE_SIGNAL, _onMaxValueChanged)

	# Visual Transformation Initialization
	if "max_value" in targetNode:
		_onMaxValueChanged(targetNode.max_value)
	if "current_value" in targetNode:
		_onValueChanged(targetNode.current_value)

	setupVisuals()
	updateColors()


func _onValueChanged(newValue: float) -> void:
	if newValue < valueBar.value:
		timer.start()
	valueBar.value = clamp(newValue, 0, valueBar.max_value)

	updateColors()

func _onMaxValueChanged(newMax: float) -> void:
	valueBar.max_value = newMax
	valueBar.value = clamp(valueBar.value, 0, valueBar.max_value)

	updateColors()

func updateColors() -> void:
	var valueRatio = valueBar.value / valueBar.max_value

	if PROGRESS_GRADIENT:
		valueBar.tint_progress = PROGRESS_GRADIENT.sample(valueRatio)

func setupVisuals() -> void:
	panel.custom_minimum_size = SIZE
	panel.position = POS

	valueBar.texture_progress = VALUE_TEXTURE
	changeBar.texture_progress = CHANGE_TEXTURE
	changeBar.texture_under = BACKGROUND_TEXTURE
	changeBar.tint_progress = CHANGE_COLOR

	changeBar.max_value = valueBar.max_value
	changeBar.value = valueBar.value



func _onTimeout() -> void:
	var tween = create_tween()
	tween.tween_property(changeBar, "value", valueBar.value, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
