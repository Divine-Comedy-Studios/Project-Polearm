extends AppState


#region Member variables

var _currentState : AppState = null
var _requestedState : AppState = null

#endregion


#region Built-in functions

func _ready() -> void:
	scene = $"LoadingScreen" as BasicLoadingScreen 
	process_mode = Node.PROCESS_MODE_DISABLED

#endregion


#region Override functions

func enter() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	scene.enter()

func exit() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

	_requestedState.delayedExit()

	_requestedState = null
	_currentState = null
	scene.exit()


func type() -> StringName:
	return Type.loading

func nextState() -> StringName:
	if _requestedState.available():
		return _requestedState.type()

	return Type.none

#endregion


#region Public functions

func requestLoad(current : AppState, request : AppState) -> StringName:
	_currentState = current
	_requestedState = request

	return Type.loading

#endregion
