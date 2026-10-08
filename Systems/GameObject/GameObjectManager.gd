extends Node
class_name GameObjectManager


#region Exported variables

@export_group("Game object config")
@export var GAME_OBJECT_DATASET : GameObjectDataset = null

#endregion


#region Member variables

var _pools : Dictionary[GameObject.Type, GameObjectPool] = { }

#endregion


#region Public functions

func spawn(type : GameObject.Type, payload : Variant) -> void:
	if not _pools.has(type):
		var pool := GameObjectPool.new(type, GAME_OBJECT_DATASET)
		_pools[type] = pool
		add_child(pool)

	_pools[type].spawn(payload)


func reset() -> void:
	for pool : GameObjectPool in _pools.values():
		pool.reset()

#endregion
