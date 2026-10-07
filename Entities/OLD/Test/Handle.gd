extends GameObject


func _initImpl() -> void:
	assert(object is CubeEnemy, "Handle.gd for CubeEnemy: Object must be CubeEnemy!")

	(object as CubeEnemy).handle = self

func spawn(payload : Variant) -> void:
	assert(payload is EnemyManager.EnemySpawnData, "Handle.gd for CubeEnemy: Wrong spawn data type!")

	(object as CubeEnemy).spawn((payload as EnemyManager.EnemySpawnData).transform)
