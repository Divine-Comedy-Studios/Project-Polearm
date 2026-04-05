extends Area3D
class_name Hitbox


#region Exported variables

@export var DAMAGE : float

#endregion


#region Member variables

var _excluded : Array[Hurtbox] = [ ]

#endregion


#region Public functions

func exclude(box : Hurtbox) -> void:
	_excluded.push_back(box)

func clear() -> void:
	_excluded.clear()


func excluded(box : Hurtbox) -> bool:
	return _excluded.has(box)

#endregion
