extends GameState


#region Exported variables

@export_group("Stage config")
@export var STAGE_DATASET : StageDataset = null

#endregion


#region Scene members

@export_group("Scene members")
@export var _enemyManager : EnemyManager = null
@export var _player : Player = null

#endregion


#region Member variables

var _currentStagePath : String = String()
var _currentStageResource : PackedScene = null
var _currentStage : Stage = null


# State machine

var _nextGameState : StringName = Type.none

#endregion


#region Built-in functions

func _ready() -> void:
	pass


# Handle transitioning to the pause menu
func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if event is InputEventKey:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		_nextGameState = Type.paused

#endregion


#region Override functions

func _enter() -> void:
	if _currentStage == null:
		_loadStage()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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

# func changeStage(stageData : Stage.SaveData) -> void:
#	_clearStageData()
#	_payload = stageData
#	_nextGameState = Type.world # This should bring us to the loading screen and back

#endregion


#region Private functions

# func _clearStageData() -> void:
#	_currentStage.queue_free()
#	_currentStage = null
#	_currentStageResource = null
#	_currentStagePath = String()


func _requestLoadStage(stageType : Stage.Type) -> void:
	_currentStagePath = STAGE_DATASET.DATASET[stageType]
	var err := ResourceLoader.load_threaded_request(_currentStagePath)

	assert(err == OK, "World._requestLoadStage(): Request to load the stage resource failed!")

func _loadStage() -> void:
	assert( \
		ResourceLoader.load_threaded_get_status(_currentStagePath) == ResourceLoader.THREAD_LOAD_LOADED, \
		"World._loadStage(): Scene resource has not finished loading! Please use the World.available() function.")

	_currentStageResource = ResourceLoader.load_threaded_get(_currentStagePath)
	_currentStage = _currentStageResource.instantiate()

	# Initialize all world components
	_enemyManager.init(_currentStage.DATA)
	_player.spawn(_currentStage.DATA.PLAYER_SPAWN_LOCATION)

	add_child(_currentStage)

#endregion
