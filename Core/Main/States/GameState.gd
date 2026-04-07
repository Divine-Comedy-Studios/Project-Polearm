extends AppState
class_name GameState


#region Built-in functions

func _ready() -> void:
	var err := ResourceLoader.load_threaded_request(SCENE_PATH)

	assert(err == OK, "GameState._ready(): Request to load the scene resource failed!")

#endregion


#region Public functions

func finishedLoading() -> bool:
	match ResourceLoader.load_threaded_get_status(SCENE_PATH):
		ResourceLoader.THREAD_LOAD_LOADED:
			return true
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
		_:
			assert(false, "GameState.finishedLoading(): Loading scene resource failed")
	
	return false

#endregion


#region Implementation functions

func _implCreateScene() -> Node:
	assert(
		ResourceLoader.load_threaded_get_status(SCENE_PATH) == ResourceLoader.THREAD_LOAD_LOADED, \
		"GameState.createSceneImpl(): Scene resource has not finished loading! Please use the GameState.finishedLoading() function.")

	_sceneResource = ResourceLoader.load_threaded_get(SCENE_PATH)
	return _sceneResource.instantiate()


func type() -> int:
	return Main.Type.game

func nextState() -> int:
	return Main.Type.none

#endregion
