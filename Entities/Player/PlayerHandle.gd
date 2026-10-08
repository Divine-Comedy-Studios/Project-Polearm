extends GameObject
class_name PlayerHandle


#region Override functions

func _initImpl() -> void:
	assert(object is Player, "PlayerHandle._initImpl(): Object must be a Player!")


func spawn(payload : Variant) -> void:
	assert(payload is Transform3D, "PlayerHandle.spawn(): Wrong spawn data type!")

	(object as Player).spawn(payload as Transform3D)

func _kill() -> void:
	(object as Player).kill()

#endregion
