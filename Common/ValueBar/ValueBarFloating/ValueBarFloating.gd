class_name ValueBarFloating extends Sprite3D

#region Exported Variables

@export_group("Connection Settings")
@export var SIGNAL_NAME : StringName = &"valueChanged"
@export var MAX_VALUE_SIGNAL : StringName = &"maxValueChanged"

@export_group("Value Setting")

@export_group("Visual Transform Settings")
@export var SIZE := Vector2(200, 15)
@export var VALUE_TEXTURE : Texture2D
@export var CHANGE_TEXTURE : Texture2D
@export var BACKGROUND_TEXTURE : Texture2D
@export var PROGRESS_GRADIENT : Gradient
@export var CHANGE_COLOR := Color8(255,255,255)

#endregion 

#region Node Variables

@onready var subViewport : SubViewport = $"3D" 
@onready var timer : Timer = $"Timer"
@onready var panel : Panel = $"3D/Panel"
@onready var changeBar : TextureProgressBar = $"3D/Panel/ChangeBar"
@onready var valueBar : TextureProgressBar = $"3D/Panel/ValueBar"

#endregion

func _ready() -> void:
	# 1. Get the parent (The Cube)
	var targetNode = get_parent()
	
	# 2. Connection Initialization
	# Check if the parent actually has the signal before connecting
	if targetNode.has_signal(SIGNAL_NAME):
		targetNode.connect(SIGNAL_NAME, _onValueChanged)
	else:
		push_error("ValueBar Error: Parent '%s' is missing signal: %s" % [targetNode.name, SIGNAL_NAME])

	if targetNode.has_signal(MAX_VALUE_SIGNAL):
		targetNode.connect(MAX_VALUE_SIGNAL, _onMaxValueChanged)

	# 3. Pull Initial Data (The "Race Condition" fix)
	if "max_value" in targetNode:
		_onMaxValueChanged(targetNode.max_value)
	if "current_value" in targetNode:
		_onValueChanged(targetNode.current_value)

	# 4. Visual Transformation Initialization
	setupVisuals()
	updateColors()

func _onValueChanged(newValue: float) -> void:
	# Start timer for the red bar delay if taking damage
	if newValue < valueBar.value:
		timer.start()
		
	valueBar.value = clamp(newValue, 0, valueBar.max_value)
	updateColors()

func _onMaxValueChanged(newMax: float) -> void:
	valueBar.max_value = newMax
	changeBar.max_value = newMax # Ensure background bar updates its scale too
	
	valueBar.value = clamp(valueBar.value, 0, valueBar.max_value)
	changeBar.value = valueBar.value # Sync background bar on max change
	
	updateColors()

func updateColors() -> void:
	if valueBar.max_value <= 0: return
	var valueRatio = valueBar.value / valueBar.max_value

	if PROGRESS_GRADIENT:
		valueBar.tint_progress = PROGRESS_GRADIENT.sample(valueRatio)

func setupVisuals() -> void:
	# Configure the Viewport and Panel sizes
	subViewport.size = SIZE
	panel.custom_minimum_size = SIZE
	
	# Apply textures
	valueBar.texture_progress = VALUE_TEXTURE
	changeBar.texture_progress = CHANGE_TEXTURE
	changeBar.texture_under = BACKGROUND_TEXTURE
	changeBar.tint_progress = CHANGE_COLOR

	# Link Viewport to Sprite3D (Automatic texture setup)
	self.texture = subViewport.get_texture()

	# Initial sync
	changeBar.max_value = valueBar.max_value
	changeBar.value = valueBar.value

func _onTimeout() -> void:
	# The smooth catch-up effect
	var tween = create_tween()
	tween.tween_property(changeBar, "value", valueBar.value, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
