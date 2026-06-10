extends AppStateMachine


#region Constants

# const WORLD_PATH : String = "res://Core/Game/World/World.tscn"
const WORLD_PATH : String = "res://Stages/Documentation/Gym/Gym_ZWISCHENABGABE.tscn"
const PAUSE_MENU_PATH : String = "res://Core/Game/PauseMenu/PauseMenu.tscn"
const STAGE_SELECT_PATH : String = "res://Core/Game/PauseMenu/PauseMenu.tscn"

#endregion


#region Scene members

var _world : AppState = null
var _pauseMenu : AppState = null

#endregion


#region Member variables

# Game state

var saveData : Dictionary = { }


# Scene loading

var _worldResource : PackedScene = null
var _pauseMenuResource : PackedScene = null


# State machiene

var exitState : StringName = AppState.Type.none:
	get():
		var tmp := exitState
		exitState = AppState.Type.none
		return tmp
	set(value):
		exitState = value

var payload : Variant = null:
	get:
		var tmp = payload
		payload = null
		return tmp
	set(value):
		payload = value

#endregion


#region Built-in functions

func _ready() -> void:
	super._ready()

	_requestLoadScene(WORLD_PATH)
	_requestLoadScene(PAUSE_MENU_PATH)

#endregion


#region Override functions

func _initialState() -> StringName:
	return AppState.Type.loading


func _nextState() -> StringName:
	var current := currentState as AppState
	var next := current.nextState()
	if next == AppState.Type.none:
		return AppState.Type.none

	var nextState := state(next) as AppState
	if current.type() == AppState.Type.loading:
		return next

	assert(current is GameState, "Game._nextState(): All game states should inherit from GameState EXCEPT and ONLY except the loading screen!")
	payload = (current as GameState).payload

	if not nextState.available():
		return loadingScreen.requestLoad(current, nextState)

	return next

#endregion


#region Public functions

func enter(saveSlot : int) -> void:
	saveData = SaveUtility.loadSave(saveSlot)
	if saveData.is_empty():
		push_error("Safe file corrupted lmaaaooooooooo aint loading that skill issue") ### @todo Replace with actual menu
		loadingScreen.requestLoad(loadingScreen, null)
	else:
		loadingScreen.requestLoad(loadingScreen, null)
		_CO_instantiateScenes()

func save(saveSlot : int) -> void:
	if not SaveUtility.writeSave(saveData, saveSlot):
		push_error("Safe file corrupted lmaaaooooooooo wont save + skill issue") ### @todo Replace with actual menu
		loadingScreen.requestLoad(loadingScreen, null)

#endregion


#region Private functions

# Scene loading

func _requestLoadScene(path : String) -> void:
	var err := ResourceLoader.load_threaded_request(path)
	assert(err == OK, "Game._ready(): Request to load scene failed!")

func _CO_instantiateScenes() -> void:
	while (not (_available(WORLD_PATH) and _available(PAUSE_MENU_PATH))):
		await get_tree().process_frame

	if _world == null:
		_worldResource = ResourceLoader.load_threaded_get(WORLD_PATH)
		_world = _worldResource.instantiate()
		add_child(_world)
		insertState(_world)
	if _pauseMenu == null:
		_pauseMenuResource = ResourceLoader.load_threaded_get(PAUSE_MENU_PATH)
		_pauseMenu = _pauseMenuResource.instantiate()
		add_child(_pauseMenu)
		insertState(_pauseMenu)

	loadingScreen.requestLoad(loadingScreen, _world as AppState)


# State machine availability

func _available(path : String) -> bool:
	match ResourceLoader.load_threaded_get_status(path):
		ResourceLoader.THREAD_LOAD_LOADED:
			return true
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
		_:
			assert(false, "Game.available(): Loading scene resource failed")

	return false

#endregion
