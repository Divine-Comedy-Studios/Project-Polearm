extends Area3D
class_name Hitbox


#region Helper classes

class Data extends Resource:
	var damage : float = 0.0
	var superArmorDamage : float = 0.0
	var force : Vector3 = Vector3.ZERO

#endregion


#region Member variables

var data : Data = null

var _excluded : Array[Hurtbox] = [ ]

#endregion


#region Built-in functions

func _ready() -> void:
	monitoring = false
	monitorable = false

#endregion


#region Public functions

func enable(hitData : Data) -> void:
	data = hitData
	monitorable = true

func disable() -> void:
	data = null
	monitorable = false

	clear()


func exclude(box : Hurtbox) -> void:
	_excluded.push_back(box)

func clear() -> void:
	_excluded.clear()


func excluded(box : Hurtbox) -> bool:
	return _excluded.has(box)

#endregion
