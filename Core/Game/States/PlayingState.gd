extends AppState
class_name PlayingState


#region Build-in functions

func _ready() -> void:
	var err := ResourceLoader.load_threaded_request(SCENE_PATH)

	assert(err == OK, "PlayingState._ready(): Request to load the scene resource failed!")

#endregion


#region Public functions

func finishedLoading() -> bool:
	match ResourceLoader.load_threaded_get_status(SCENE_PATH):
		ResourceLoader.THREAD_LOAD_LOADED:
			return true
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
		_:
			assert(false, "PlayingState.finishedLoading(): Loading scene resource failed")
	
	return false

#endregion


#region Override functions

func _implCreateScene() -> Node:
	assert( \
		ResourceLoader.load_threaded_get_status(SCENE_PATH) == ResourceLoader.THREAD_LOAD_LOADED, \
		"PlayingState.createSceneImpl(): Scene resource has not finished loading! Please use the PlayingState.finishedLoading() function.")

	_sceneResource = ResourceLoader.load_threaded_get(SCENE_PATH)
	return _sceneResource.instantiate()


func type() -> StringName:
	return Game.Type.playing

#endregion
