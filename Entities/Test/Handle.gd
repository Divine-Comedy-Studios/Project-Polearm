extends GameObject


func _initImpl() -> void:
	assert(object is CubeEnemy, "Handle.gd for CubeEnemy: Object must be CubeEnemy!")

	(object as CubeEnemy).handle = self

func spawn(payload : Variant) -> void:
	assert(payload is EnemyManager.EnemySpawnData, "Handle.gd for CubeEnemy: Wrong spawn data type!")

	var transform := Transform3D.IDENTITY
	
	(object as CubeEnemy).spawn(transform.translated(Vector3(0, 10, 0)))
