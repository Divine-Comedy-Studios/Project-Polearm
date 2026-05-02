extends AppState


#region Imports

const Game := preload("res://Core/Game/Game.gd")

#endregion


#region Built-in functions

func _ready() -> void:
	var err := ResourceLoader.load_threaded_request(SCENE_PATH)

	assert(err == OK, "GameState._ready(): Request to load the scene resource failed!")

#endregion


#region Override functions

func _implCreateScene() -> Node:
	assert(
		ResourceLoader.load_threaded_get_status(SCENE_PATH) == ResourceLoader.THREAD_LOAD_LOADED, \
		"GameState.createSceneImpl(): Scene resource has not finished loading! Please use the GameState.finishedLoading() function.")

	_sceneResource = ResourceLoader.load_threaded_get(SCENE_PATH)
	return _sceneResource.instantiate()


func type() -> StringName:
	return Type.game

func nextState() -> StringName:
	assert(scene != null, "GameState.nextState(): Game has to be properly instantiated!")

	return (scene as Game).exitState


func delayedExit() -> void:
	_unload()
	_sceneResource = null

func available() -> bool:
	match ResourceLoader.load_threaded_get_status(SCENE_PATH):
		ResourceLoader.THREAD_LOAD_LOADED:
			return true
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
		_:
			assert(false, "GameState.available(): Loading scene resource failed")
	
	return false

#endregion
