@tool

extends Area3D
class_name Hitbox


#region Helper classes

class Data extends Resource:
	var damage : float = 0.0
	var superArmorDamage : float = 0.0
	var force : Vector3 = Vector3.ZERO

#endregion


#region Exported variables

@export_flags_3d_physics var layers : int:
	get:
		return collision_mask
	set(value):
		collision_mask = value

#endregion


#region Member variables

var _data : Data = null

var _excluded : Array[Hurtbox] = [ ]

#endregion


#region Built-in functions

func _ready() -> void:
	if Engine.is_editor_hint():
		collision_layer = 0

		monitoring = false # true if a hitbox should be enabled on start
		monitorable = false

	area_entered.connect(_onHit)

#endregion


#region Public functions

func enable(hitData : Data) -> void:
	_data = hitData
	monitoring = true

func disable() -> void:
	monitoring = false

	clear()


func exclude(box : Hurtbox) -> void:
	_excluded.push_back(box)

func clear() -> void:
	_excluded.clear()


func excluded(box : Hurtbox) -> bool:
	return _excluded.has(box)

#endregion


#region Signal functions

func _onHit(area : Area3D) -> void:
	if not area is Hurtbox:
		return

	var box := area as Hurtbox
	if _excluded.has(box):
		return

	_excluded.push_back(box)
	box.recieveHit(_data)

#endregion
