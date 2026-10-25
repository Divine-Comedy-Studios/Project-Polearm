extends BasicEnemyResources
class_name SoliderResources


#region Implementation functions

func _takeDamage(hitData : HitboxData) -> void:
	(actionManager.entity as FloatingBody).setMovement(hitData.directionalForce)

#endregion
