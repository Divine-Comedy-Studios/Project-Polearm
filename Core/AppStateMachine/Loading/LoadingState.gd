extends AppState


#region Scene members

@onready var loadingScreen := $LoadingScreen as BasicLoadingScreen

#endregion


#region Member variables

var _currentState : AppState = null
var _requestedState : AppState = null

#endregion


#region Built-in functions

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT

#endregion


#region Override functions

func enter() -> void:
	loadingScreen.enter()

func exit() -> void:
	_currentState.delayedExit()

	_requestedState = null
	_currentState = null
	loadingScreen.exit()


func type() -> StringName:
	return Type.loading

func nextState() -> StringName:
	if _requestedState == null:
		return Type.none
	if not _requestedState.available():
		return Type.none

	return _requestedState.type()

#endregion


#region Public functions

func requestLoad(current : AppState, request : AppState) -> StringName:
	_currentState = current
	_requestedState = request

	return Type.loading

#endregion
