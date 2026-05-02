extends AppState


#region Built-in functions

func _ready() -> void:
	var err := ResourceLoader.load_threaded_request(SCENE_PATH)

	assert(err == OK, "MainMenuState._ready(): Request to load the scene resource failed!")

#endregion


#region Override functions

func _implCreateScene() -> Node:
	assert( \
		ResourceLoader.load_threaded_get_status(SCENE_PATH) == ResourceLoader.THREAD_LOAD_LOADED, \
		"MainMenuState.createSceneImpl(): Scene resource has not finished loading! Please use the MainMenuState.finishedLoading() function.")

	_sceneResource = ResourceLoader.load_threaded_get(SCENE_PATH)
	return _sceneResource.instantiate()


func available() -> bool:
	match ResourceLoader.load_threaded_get_status(SCENE_PATH):
		ResourceLoader.THREAD_LOAD_LOADED:
			return true
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
		_:
			assert(false, "MainMenuState.available(): Loading scene resource failed")
	
	return false

func delayedExit() -> void:
	_unload()
	_sceneResource = null

func type() -> StringName:
	return Type.mainMenu

func nextState() -> StringName:
	return scene.exit()

#endregion
