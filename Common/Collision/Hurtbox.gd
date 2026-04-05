extends Area3D
class_name Hurtbox


#region Member variables

var _hitbox : Hitbox = null

#endregion


#region Built-in funcitons

func _ready() -> void:
	area_entered.connect(_onHit)

#endregion


#region Public functions

func popHitbox() -> Hitbox:
	var tmp := _hitbox
	_hitbox = null
	return tmp

#endregion


#region Signal functions

func _onHit(area : Area3D) -> void:
	if area is Hitbox:
		var box := area as Hitbox
		if not box.excluded(self):
			_hitbox = box
			_hitbox.exclude(self)

#endregion
