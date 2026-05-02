extends AppStateMachine


#region Constants

const WORLD_PATH : String = "res://Core/Game/World/World.tscn"

#endregion


#region Scene members

var _world : AppState = null

#endregion


#region Member variables

var _worldResource : PackedScene = null

var exitState : StringName = AppState.Type.none:
	get():
		var tmp := exitState
		exitState = AppState.Type.none
		return tmp
	set(value):
		exitState = value

#endregion


#region Built-in functions

func _ready() -> void:
	super._ready()

	var err := ResourceLoader.load_threaded_request(WORLD_PATH)
	assert(err == OK, "Game._ready(): Request to load the scene resource failed!")


func _process(delta : float) -> void:
	if _world == null and available(WORLD_PATH):
		_worldResource = ResourceLoader.load_threaded_get(WORLD_PATH)
		_world = _worldResource.instantiate()
		add_child(_world)
		insertState(_world)

		loadingScreen.requestLoad(loadingScreen, _world as AppState)

	super._process(delta)

#endregion


#region Override functions

func _initialState() -> StringName:
	return AppState.Type.loading

#endregion


#region Public functions

func enter() -> void:
	loadingScreen.requestLoad(loadingScreen, null)

#endregion


#region Private functions

func available(path : String, triggerAssert : bool = true) -> bool:
	match ResourceLoader.load_threaded_get_status(path):
		ResourceLoader.THREAD_LOAD_LOADED:
			return true
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
		_:
			assert(!triggerAssert, "Game.available(): Loading scene resource failed")

	return false

#endregion
