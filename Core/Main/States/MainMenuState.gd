extends AppState
class_name MainMenuState


#region Enums

enum ExitType {
	none,
	startGame,
	quitGame,
}

#endregion


#region Scene members

@export var _game : GameState = null

#endregion


#region Built-in functions

func _ready() -> void:
	var err := ResourceLoader.load_threaded_request(SCENE_PATH)

	assert(err == OK, "MainMenuState._ready(): Request to load the scene resource failed!")

#endregion


#region Public functions

func finishedLoading() -> bool:
	match ResourceLoader.load_threaded_get_status(SCENE_PATH):
		ResourceLoader.THREAD_LOAD_LOADED:
			return true
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
		_:
			assert(false, "MainMenuState.finishedLoading(): Loading scene resource failed")
	
	return false

#endregion


#region Implementation functions

func _implCreateScene() -> Node:
	assert( \
		ResourceLoader.load_threaded_get_status(SCENE_PATH) == ResourceLoader.THREAD_LOAD_LOADED, \
		"MainMenuState.createSceneImpl(): Scene resource has not finished loading! Please use the MainMenuState.finishedLoading() function.")

	_sceneResource = ResourceLoader.load_threaded_get(SCENE_PATH)
	return _sceneResource.instantiate()


func type() -> int:
	return Main.Type.mainMenu

func nextState() -> int:
	match scene.exit() as int:
		ExitType.startGame:
			if _game.finishedLoading():
				return Main.Type.game
		ExitType.quitGame:
			return Main.Type.quit

	return Main.Type.none

#endregion
