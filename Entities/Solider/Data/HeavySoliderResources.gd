extends SoliderResources


#region Implementation functions

func _takeDamage(_hitData : HitboxData) -> void:
	if health.value <= 0.0:
		actionManager.interrupt(SoliderAction.Type.death)

#endregion
