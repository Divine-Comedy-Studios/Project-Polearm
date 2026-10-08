class_name GameObjectPool
extends Node


#region Member variables

var TYPE : GameObject.Type = GameObject.Type.none

var HandleType : Script = null

var _scene : PackedScene = null
var _scenePath : String = String()

var _pooled : Array[GameObject] = []

var active : Dictionary[int, GameObject] = { }

#endregion


#region Built-in functions

func _init(type : GameObject.Type, dataset : GameObjectDataset) -> void:
	assert(dataset != null, "GameObjectPool._init(): Game object dataset not set!")
	assert(dataset.DATASET.has(type), "GameObjectPool._init(): Game object dataset missing entry for requested entity type!")

	HandleType = load(dataset.DATASET[type].HANDLE_SCRIPT_PATH)

	TYPE = type
	_scenePath = dataset.DATASET[TYPE].SCENE_PATH

	_loadScene()

#endregion


#region Public functions

func spawn(payload : Variant) -> void:
	_checkScene()

	var object : GameObject = null

	if _pooled.is_empty():
		object = HandleType.new(_scene.instantiate(), self)
		assert(object is GameObject, "GameObjectPool.spawn(): Scene mapped to type in Game object dataset does not inherit from GameObject!")

		active[object.entityID()] = object
	else:
		object = _pooled.back()
		_pooled.pop_back()
		active[object.entityID()] = object

	add_child(object.object)

	object.spawn(payload)


func reset(deepClear : bool = false) -> void:
	for entity : GameObject in active.values():
		entity.kill()
	
	active.clear()

	if deepClear:
		_pooled.clear()

#endregion


#region Private functions

func _loadScene() -> void:
	var err := ResourceLoader.load_threaded_request(_scenePath)
	assert(err == OK, "EntityPool._ready(): Request to load entity scene failed!")

func _checkScene() -> void:
	if _scene != null:
		return

	while true:
		match ResourceLoader.load_threaded_get_status(_scenePath):
			ResourceLoader.THREAD_LOAD_LOADED:
				_scene = ResourceLoader.load_threaded_get(_scenePath)

				return
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				continue
			_:
				assert(false, "EntityPool._checkScene(): An error occured whilst loading entity scene!")
				_loadScene()

#endregion
