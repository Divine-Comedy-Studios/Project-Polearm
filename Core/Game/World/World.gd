extends GameState
class_name World


#region Exported variables

@export_group("Stage config")
@export var STAGE_DATASET : StageDataset = null

#endregion


#region Member variables

var currentStageType : Stage.Type = Stage.Type.NULL

var _currentStagePath : String = String()
var _currentStageResource : PackedScene = null
var _currentStage : Stage = null


# State machine

var _nextGameState : StringName = Type.none

#endregion


#region Built-in functions

func _ready() -> void:
	if Globals.world != null:
		push_error("World._ready(): World has already been initialized once!")
		return

	Globals.world = self


# Handle transitioning to the pause menu
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		if event is InputEventKey:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		_nextGameState = Type.paused

#endregion


#region Override functions

func _enter() -> void:
	if _currentStage == null:
		_loadStage()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	Globals.audioManager.playMusic(MusicData.Type.game)

func _exit() -> void:
	_nextGameState = Type.none


func available() -> bool:
	if _currentStage == null:
		match ResourceLoader.load_threaded_get_status(_currentStagePath):
			ResourceLoader.THREAD_LOAD_LOADED:
				return true
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				return false
			_:
				var payl : Variant = stateMachine.payload
				if payl != null:
					#assert(payl is Stage.SaveData, "World._enter(): Payload must contain current level data!")
					_requestLoadStage(payl as Stage.Type)
					return false

	return true


func type() -> StringName:
	return Type.world

func nextState() -> StringName:
	return _nextGameState

#endregion


#region Public functions

func gameOver() -> void:
	_nextGameState = Type.gameOver


func reset() -> void:
	_currentStage.queue_free()
	_currentStage = null
	_currentStageResource = null
	_currentStagePath = String()

	Globals.enemyManager.reset()
	Globals.gameObjectManager.reset()

# func changeStage(stageData : Stage.SaveData) -> void:
#	_clearStageData()
#	_payload = stageData
#	_nextGameState = Type.world # This should bring us to the loading screen and back

#endregion


#region Private functions

func _requestLoadStage(stageType : Stage.Type) -> void:
	currentStageType = stageType

	_currentStagePath = STAGE_DATASET.DATASET[currentStageType]
	var err := ResourceLoader.load_threaded_request(_currentStagePath)

	assert(err == OK, "World._requestLoadStage(): Request to load the stage resource failed!")

func _loadStage() -> void:
	assert( \
		ResourceLoader.load_threaded_get_status(_currentStagePath) == ResourceLoader.THREAD_LOAD_LOADED, \
		"World._loadStage(): Scene resource has not finished loading! Please use the World.available() function.")

	_currentStageResource = ResourceLoader.load_threaded_get(_currentStagePath)
	_currentStage = _currentStageResource.instantiate()

	# Initialize all world components
	Globals.gameObjectManager.spawn(GameObject.Type.player, _currentStage.DATA.PLAYER_SPAWN_TRANSFORM)

	add_child(_currentStage)

#endregion
