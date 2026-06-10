@tool

extends Panel
class_name ValueBarUI


#region Scene members

@export_group("Scene members")
@export var timer : Timer = null
@export var changeBar : TextureProgressBar = null
@export var valueBar : TextureProgressBar = null

#endregion


#region Exported Variables

@export_group("Value resource")

@export var valueResource : ValueResource = null:
	set(value):
		valueResource = value

		if valueResource == null:
			return

		valueResource.valueChanged.connect(_onValueChanged)
		valueResource.maxValueChanged.connect(_onMaxValueChanged)

		if changeBar and valueBar:
			changeBar.max_value = valueResource.maxValue
			changeBar.value = valueResource.value
			valueBar.max_value = valueResource.maxValue
			valueBar.value = valueResource.value

			updateColors()


@export_group("Color")

@export var PROGRESS_GRADIENT : Gradient = null

@export var CHANGE_COLOR : Color:
	set(value):
		if changeBar:
			changeBar.tint_progress = value
	get:
		return changeBar.tint_progress


@export_group("Textures")

@export var VALUE_TEXTURE : Texture2D:
	set(value):
		if valueBar:
			valueBar.texture_progress = value
	get:
		return valueBar.texture_progress

@export var CHANGE_TEXTURE : Texture2D:
	set(value):
		if changeBar:
			changeBar.texture_progress = value
	get:
		return changeBar.texture_progress

@export var BACKGROUND_TEXTURE : Texture2D:
	set(value):
		if changeBar:
			changeBar.texture_under = value
	get:
		return changeBar.texture_under
	

@export_group("Timer")
@export var CHANGE_WAIT_TIME : float:
	set(value):
		if changeBar:
			timer.wait_time = value
	get:
		return timer.wait_time

#endregion


#region Built-in funcitons

func _ready() -> void:
	if not Engine.is_editor_hint():
		assert(valueResource != null, "ValueBar._ready(): Resource not set!")

		updateColors()

#endregion


#region Public funcitons

func updateColors() -> void:
	var valueRatio = valueBar.value / valueBar.max_value

	if PROGRESS_GRADIENT:
		valueBar.tint_progress = PROGRESS_GRADIENT.sample(valueRatio)

#endregion


#region Private functions

func _onValueChanged(newValue: float) -> void:
	if newValue < valueBar.value:
		timer.start()
	changeBar.value = valueBar.value
	valueBar.value = clamp(newValue, 0, valueBar.max_value)

	updateColors()

func _onMaxValueChanged(newMax: float) -> void:
	valueBar.max_value = newMax
	valueBar.value = clamp(valueBar.value, 0, valueBar.max_value)

	updateColors()

#endregion


#region Signal functions

func _onTimeout() -> void:
	var tween = create_tween()
	tween.tween_property(changeBar, "value", valueBar.value, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

#endregion
