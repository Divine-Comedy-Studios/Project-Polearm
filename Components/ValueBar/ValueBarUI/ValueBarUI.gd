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


@export_group("Tweening")
@export var VALUE_TWEEN_DURATION : float = 0.2
@export var CHANGE_TWEEN_DURATION : float = 0.5

#endregion


#region Built-in funcitons

func _ready() -> void:
	if not Engine.is_editor_hint():
		assert(valueResource != null, "ValueBar._ready(): Resource not set!")


func _physics_process(_delta: float) -> void:
	var valueRatio = valueBar.value / valueBar.max_value

	if PROGRESS_GRADIENT:
		valueBar.tint_progress = PROGRESS_GRADIENT.sample(valueRatio)

#endregion


#region Private functions

func _onValueChanged(newValue: float) -> void:
	if timer.is_stopped():
		changeBar.value = valueBar.value

	if is_inside_tree() and newValue < valueBar.value:
		timer.start()

	valueBar.value = newValue


func _onMaxValueChanged(newMax: float) -> void:
	valueBar.max_value = newMax
	valueBar.value = clamp(valueBar.value, 0, valueBar.max_value)

#endregion


#region Signal functions

func _onTimeout() -> void:
	create_tween().tween_property(changeBar, "value", valueResource.value, CHANGE_TWEEN_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

#endregion
