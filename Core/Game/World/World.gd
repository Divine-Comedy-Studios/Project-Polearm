extends GameState


#region Exported variables

@export var STAGE_PATHS : Dictionary[Stage.Type, String] = { }

#endregion


#region Member variables

# Stage

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
func _input(event : InputEvent) -> void:
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
					assert(payl is Stage.SaveData, "World._enter(): Payload must contain current level data!")
					_requestLoadStage(payl as Stage.SaveData)
					return false

	return true


func type() -> StringName:
	return Type.world

func nextState() -> StringName:
	return _nextGameState

#endregion


#region Public functions

func changeStage(stageData : Stage.SaveData) -> void:
	_clearStageData()
	_payload = stageData
	_nextGameState = Type.world # This should bring us to the loading screen and back

#endregion


#region Private functions

func _clearStageData() -> void:
	_currentStage.queue_free()
	_currentStage = null
	_currentStageResource = null
	_currentStagePath = String()


func _requestLoadStage(stageData : Stage.SaveData) -> void:
	pass

func _loadStage() -> void:
	_currentStage = _currentStageResource.instantiate()
	add_child(_currentStage)

	# Do something

#endregion
