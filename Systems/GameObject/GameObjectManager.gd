extends Node
class_name GameObjectManager


#region Exported variables

@export_group("Game object config")
@export var GAME_OBJECT_DATASET : GameObjectDataset = null

#endregion


#region Member variables

var _pools : Dictionary[GameObject.Type, GameObjectPool] = { }

#endregion


#region Built-in functions

func _ready() -> void:
	if Globals.gameObjectManager != null:
		push_error("GameObjectManager._ready(): Game object manager has already been initialized once!")
		return

	Globals.gameObjectManager = self

	for type : GameObject.Type in GAME_OBJECT_DATASET.DATASET.keys():
		var preInitCount := GAME_OBJECT_DATASET.DATASET[type].PREINITIALIZE
		if preInitCount > 0:
			_addPool(type).prepare(preInitCount)

#endregion


#region Public functions

func spawn(type : GameObject.Type, payload : Variant) -> void:
	(_pools[type] if _pools.has(type) else _addPool(type)).spawn(payload)


func reset() -> void:
	for pool : GameObjectPool in _pools.values():
		pool.reset()

#endregion


#region Private functions

func _addPool(type : GameObject.Type) -> GameObjectPool:
	var pool := GameObjectPool.new(type, GAME_OBJECT_DATASET)
	_pools[type] = pool
	add_child(pool)

	return pool

#endregion
