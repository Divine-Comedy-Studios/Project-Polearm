extends AppStateMachine


#region Scene members

@export_group("Scene members")
@export var _world : AppState = null
@export var _pauseMenu : AppState = null

#endregion


#region Member variables

# Game state

var saveData : Dictionary = { }


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
	assert(_world != null, "Game._ready(): Please assign the game world!")
	assert(_pauseMenu != null, "Game._ready(): Please assign the pause menu!")

	super._ready()

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

# func enter(saveData : SaveUtility.Data) -> void:
	# saveData = Globals.saveUtility.loadSave(saveSlot)
	# if saveData.is_empty():
	#	push_error("Safe file corrupted lmaaaooooooooo aint loading that skill issue") ### @todo Replace with actual menu
	#	loadingScreen.requestLoad(loadingScreen, null)
	# else:

func enter() -> void:
	Globals.audioManager.playMusic(Audio.MusicType.game)
	payload = Stage.Type.GYM
	loadingScreen.requestLoad(loadingScreen, _world as AppState)


# func save(saveSlot : int) -> void:
#	if not Globals.saveUtility.writeSave(saveData, saveSlot):
#		push_error("Safe file corrupted lmaaaooooooooo wont save + skill issue") ### @todo Replace with actual menu
#		loadingScreen.requestLoad(loadingScreen, null)

#endregion
