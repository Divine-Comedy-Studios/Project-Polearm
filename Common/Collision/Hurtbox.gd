extends Area3D
class_name Hurtbox


#region Built-in funcitons

func _ready() -> void:
	area_entered.connect(_onHit)

	monitorable = false

#endregion


#region Signal functions

func _onHit(area : Area3D) -> void:
	if not area is Hitbox:
		return

	var box := area as Hitbox
	if box.excluded(self):
		return

	box.exclude(self)
	_implHit(box)

#endregion


#region Implementation functions

func _implHit(hitbox : Hitbox) -> void:
	pass

#endregion
