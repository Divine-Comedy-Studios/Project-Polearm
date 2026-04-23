extends Area3D
class_name Hurtbox


#region Built-in functions

func _ready() -> void:
	area_entered.connect(_onHit)

	monitorable = false
	monitoring = true

#endregion


#region Public functions

func enable() -> void:
	monitoring = true

func disable() -> void:
	monitoring = false

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

@warning_ignore("unused_parameter")
func _implHit(hitbox : Hitbox) -> void:
	pass

#endregion
