extends BasicEnemyResources
class_name SoliderResources


#region Implementation functions

func _takeDamage(hitData : HitboxData) -> void:
	# @todo Verify that setMovement() with the world space directionalForce is the right way to apply knockback
	# (the old CubeEnemy body added it to its velocity). Might want a dedicated knockback function on FloatingBody.
	(actionManager.entity as FloatingBody).setMovement(hitData.directionalForce)

#endregion
