extends BasicStateMachine
class_name AppStateMachine


#region Built-in functions

func _ready() -> void:
	init()

func _process(_delta : float) -> void:
	updateStates()

#endregion


#region Override functions

func _implChildInit(child : Node) -> void:
	if child is AppState:
		states[child.type()] = child as BasicState

func _implInit() -> void:
	_enterState(_initialState())


func _nextState() -> int:
	return _currentState.nextState()

#endregion


#region Virtual functions

func _initialState() -> int:
	return 0

#endregion
