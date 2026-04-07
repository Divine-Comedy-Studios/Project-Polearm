extends Node
class_name BasicStateMachine


#region Member variables

var states : Dictionary[int, BasicState] = { }

var _currentState : BasicState = null

var _interruptState : int = 0

#endregion


#region Public functions

func init() -> void:
	for child in get_children():
		_implChildInit(child)
	
	_implInit()

func updateStates() -> void:
	var nextState := _nextState()
	if nextState != 0:
		_exitCurrentState()
		_enterState(nextState)


func interrupt(type : int) -> void:
	_interruptState = type

#endregion


#region Private functions

func _exitCurrentState() -> void:
	_currentState.exit()

func _enterState(type : int) -> void:
	_currentState = states[type]
	_currentState.enter()

#endregion


#region Implementation & Virtual functions

func _implChildInit(_child : Node) -> void:
	pass

func _implInit() -> void:
	pass


func _nextState() -> int:
	return 0

#endregion
