class_name ValueBar extends Sprite3D

#region Exported Variables

@export_group("Connection Settings")
@export var GROUP_NAME : StringName
@export var GROUP_INDEX : int
@export var SIGNAL_NAME : StringName = &"valueChanged"
@export var MAX_VALUE_SIGNAL : StringName = &"maxValueChanged"

@export_group("Value Setting")

@export_group("Visual Transform Settings")
@export var SIZE := Vector2(1000, 50)
@export var VALUE_TEXTURE : Texture2D
@export var CHANGE_TEXTURE : Texture2D
@export var BACKGROUND_TEXTURE : Texture2D
@export var PROGRESS_GRADIENT : Gradient


#endregion 

#region Node Variables

@onready var subViewport : SubViewport = $"SubViewport" 
@onready var panel : Panel = $"SubViewport/Panel"
@onready var changeBar : TextureProgressBar = $"SubViewport/Panel/ChangeBar"
@onready var valueBar : TextureProgressBar = $"SubViewport/Panel/ChangeBar/ValueBar"

#endregion

func _ready() -> void:
	var nodes = get_tree().get_nodes_in_group(GROUP_NAME)

	assert(nodes.size() > GROUP_INDEX, "ValueBar Error: No node found in group %s at index %d" % [GROUP_NAME, GROUP_INDEX])

	var targetNode = nodes[GROUP_INDEX]

	if targetNode.has_signal(SIGNAL_NAME):
		targetNode.connect(SIGNAL_NAME, _onValueChanged)
	else:
		assert(false, "ValueBar Error: Target node missing signal: " + SIGNAL_NAME)

	if targetNode.has_signal(MAX_VALUE_SIGNAL):
		targetNode.connect(MAX_VALUE_SIGNAL, _onMaxValueChanged)


func _onValueChanged(newValue: float) -> void:
	valueBar.value = clamp(newValue, 0, valueBar.max_value)

	updateColors()

func _onMaxValueChanged(newMax: float) -> void:
	valueBar.max_value = newMax
	valueBar.value = clamp(valueBar.value, 0, valueBar.max_value)

	updateColors()

func updateColors() -> void:
	var valueRatio = valueBar.value / valueBar.max_value

	if PROGRESS_GRADIENT:
		valueBar.self_modulate = PROGRESS_GRADIENT.sample(valueRatio)
