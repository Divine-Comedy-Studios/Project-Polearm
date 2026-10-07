extends StaticBody3D
class_name Door


#region Signals

signal activated
signal deactivated

#endregion


#region Imports

const FIELD_SHADER := preload("res://Objects/Door/DoorField.gdshader")

#endregion


#region Exported variables

@export_group("Door")
## Active = force field is up and the hitbox blocks the way
@export var startActive : bool = true
## Width and height of the door in meters (the origin of the door is at its feet)
@export var size : Vector2 = Vector2(3.0, 4.0)
@export var thickness : float = 0.3
@export var transitionTime : float = 0.6

@export_group("Look")
@export var fieldColor : Color = Color(0.2, 0.7, 1.0)
@export var intensity : float = 2.0
@export var lightEnergy : float = 1.5

#endregion


#region Scene members

@onready var _collision := $CollisionShape3D as CollisionShape3D
@onready var _field := $Field as MeshInstance3D
@onready var _light := $Light as OmniLight3D

#endregion


#region Member variables

var _active : bool = true
var _material : ShaderMaterial = null
var _tween : Tween = null

#endregion


#region Built-in functions

func _ready() -> void:
	# Meshes, shapes and materials are created here so every door instance owns its own copy
	var mesh := QuadMesh.new()
	mesh.size = size
	_field.mesh = mesh
	_field.position.y = size.y * 0.5

	var shape := BoxShape3D.new()
	shape.size = Vector3(size.x, size.y, thickness)
	_collision.shape = shape
	_collision.position.y = size.y * 0.5

	_light.position.y = size.y * 0.5

	_material = ShaderMaterial.new()
	_material.shader = FIELD_SHADER
	_material.set_shader_parameter("field_color", fieldColor)
	_material.set_shader_parameter("intensity", intensity)
	_material.set_shader_parameter("field_size", size)
	_field.material_override = _material

	_applyInstant(startActive)

#endregion


#region Public functions

func isActive() -> bool:
	return _active


func activate() -> void:
	setActive(true)


func deactivate() -> void:
	setActive(false)


func toggle() -> void:
	setActive(not _active)


func setActive(value : bool) -> void:
	if value == _active:
		return
	_active = value

	# Hitbox switches immediately, the visuals fade over transitionTime
	_collision.set_deferred("disabled", not value)

	if _tween != null:
		_tween.kill()

	if value:
		_field.show()
		_light.show()

	_tween = create_tween().set_parallel(true)
	_tween.tween_method(_setProgress, _getProgress(), 1.0 if value else 0.0, transitionTime)
	_tween.tween_property(_light, "light_energy", lightEnergy if value else 0.0, transitionTime)

	if not value:
		_tween.chain().tween_callback(_hideVisuals)

	if value:
		activated.emit()
	else:
		deactivated.emit()

#endregion


#region Private functions

func _applyInstant(value : bool) -> void:
	_active = value
	_collision.disabled = not value
	_setProgress(1.0 if value else 0.0)
	_light.light_energy = lightEnergy if value else 0.0
	_field.visible = value
	_light.visible = value


func _getProgress() -> float:
	return _material.get_shader_parameter("progress") as float


func _setProgress(value : float) -> void:
	_material.set_shader_parameter("progress", value)


func _hideVisuals() -> void:
	_field.hide()
	_light.hide()

#endregion
