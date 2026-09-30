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
	assert(dataset != null, "GameObjectPool._init(): GAME_OBJECT_DATASET not set!")
	assert(dataset.DATASET.has(type), "GameObjectPool._init(): GAME_OBJECT_DATASET does not contain an entry for the given entity type!")

	TYPE = type
	HandleType = load(dataset.DATASET[type].HANDLE_SCRIPT_PATH)
	_scenePath = dataset.DATASET[TYPE].SCENE_PATH

	_loadScene()

#endregion


#region Public functions

func spawn(payload : Variant) -> void:
	_checkScene()

	var object : GameObject = null

	if _pooled.is_empty():
		object = HandleType.new(_scene.instantiate(), self)
		assert(object is GameObject, "GameObjectPool.spawn(): Handle Type passed from GAME_OBJECT_DATASET does not inherit GameObject")

		active[object.entityID()] = object
	else:
		object = _pooled.back()
		_pooled.pop_back()
		active[object.entityID()] = object

	object.spawn(payload)

	add_child(object.object)


func clear() -> void:
	for entity : GameObject in active.values():
		entity.kill()
	
	active.clear()
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
