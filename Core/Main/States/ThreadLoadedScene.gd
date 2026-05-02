extends AppState
class_name MainThreadLoadedScene


#region Exported variables

@export_file_path("*tscn", "*scn") var SCENE_PATH : String = ""

#endregion


#region Member variables

var _sceneResource : PackedScene = null

var scene : Node = null

#endregion


#region Built-in functions

func _ready() -> void:
	_loadScene()

#endregion


#region Override functions

func enter() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT

	scene = _createScene()
	add_child(scene)

func exit() -> void:
	_unload()
	_sceneResource = null

	process_mode = Node.PROCESS_MODE_DISABLED


func available() -> bool:
	match ResourceLoader.load_threaded_get_status(SCENE_PATH):
		ResourceLoader.THREAD_LOAD_LOADED:
			return true
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
		_:
			_loadScene()
	
	return false

#endregion


#region Private functions

func _loadScene() -> void:
	var err := ResourceLoader.load_threaded_request(SCENE_PATH)

	assert(err == OK, "MainThreadLoadedScene._ready(): Request to load the scene resource failed!")

func _createScene() -> Node:
	assert( \
		ResourceLoader.load_threaded_get_status(SCENE_PATH) == ResourceLoader.THREAD_LOAD_LOADED, \
		"MainThreadLoadedScene._createSceneImpl(): Scene resource has not finished loading! Please use the MainMenuState.finishedLoading() function.")

	_sceneResource = ResourceLoader.load_threaded_get(SCENE_PATH)
	return _sceneResource.instantiate()


func _unload() -> void:
	remove_child(scene)
	scene.queue_free()
	scene = null

#endregion
