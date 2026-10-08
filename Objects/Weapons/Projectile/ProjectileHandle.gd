extends GameObject
class_name ProjectileHandle


#region Override functions

func _initImpl() -> void:
	assert(object is Projectile, "ArrowHandle._initImpl(): Object must be a Projectile!")

	(object as Projectile).handle = self


func spawn(payload : Variant) -> void:
	assert(payload is ProjectilePhysics, "ArrowHandle.spawn(): Wrong payload type!")

	(object as Projectile).spawn(payload as ProjectilePhysics)


func _kill() -> void:
	(object as Projectile).kill()

#endregion
