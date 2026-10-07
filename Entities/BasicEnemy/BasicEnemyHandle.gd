extends GameObject
class_name BasicEnemyHandle


#region Override functions

func _initImpl() -> void:
	assert(object is BasicEnemy, "BasicEnemyHandle._initImpl(): Object must be a BasicEnemy!")

	(object as BasicEnemy).handle = self


func spawn(payload : Variant) -> void:
	assert(payload is Transform3D, "BasicEnemyHandle.spawn(): Wrong spawn data type!")

	var transform := payload as Transform3D
	var enemy := object as BasicEnemy

	Globals.world.enemyManager.register(self)

	enemy.spawn(transform)

func _killImpl() -> void:
	Globals.world.enemyManager.unregister(self)


func tick(delta : float, payload : Variant = null) -> void:
	assert(payload is EnemyPerception.Data, "BasicEnemyHandle.tick(): Wrong payload type!")

	(object as BasicEnemy).tick(delta, payload as EnemyPerception.Data)

#endregion


#region Public functions

# Getters to the underlying object

func role() -> EnemyManager.Role:
	return (object as BasicEnemy).role()

func availableRoles() -> Array[EnemyManager.Role]:
	return (object as BasicEnemy).availableRoles()

func requestRoleChange() -> bool:
	return (object as BasicEnemy).requestRoleChange()

func position() -> Vector3:
	return (object as BasicEnemy).position()

#endregion
