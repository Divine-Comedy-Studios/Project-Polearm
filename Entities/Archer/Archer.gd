extends BasicEnemy
class_name Archer


#region Constants

const GROUND_RAY_LENGTH : float = 100.0 # Arbitrary constant

#endregion


#region Override functions

func spawn(payload : Variant) -> void:
	super.spawn(payload)

	var pos := (payload as Transform3D).origin
	var result := PhysicsServer3D.space_get_direct_state(get_world_3d().space).intersect_ray(
		PhysicsRayQueryParameters3D.create(
			pos,
			pos + Vector3.DOWN * GROUND_RAY_LENGTH,
			PPUtil.CollisionLayers.world
		)
	)

	if result.is_empty():
		return

	actionManager.entity.global_position = result["position"]

#endregion
