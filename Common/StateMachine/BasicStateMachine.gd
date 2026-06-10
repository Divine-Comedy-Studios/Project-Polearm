extends Node
class_name BasicStateMachine


#region Member variables

var _states : Dictionary[StringName, BasicState] = { }
var currentState : BasicState = null

#endregion


#region Public functions

func init() -> void:
	_states.get_or_add(BasicState.TYPE_NONE, BasicState.NONE)

	for child in get_children():
		insertState(child)

	_enterState(_initialState())


func update() -> void:
	_switchState(_nextState())

func interrupt(type : StringName) -> void:
	_switchState(_interruptState(type))


func insertAction(value : Node) -> void: insertState(value)

func action(type : StringName) -> BasicState: return state(type)
func state(type : StringName) -> BasicState:
	# return _states.get(type, BasicState.NONE) as BasicState
	print(type)
	return _states.get(type) as BasicState

#endregion


#region Private functions

func _addState(value : BasicState) -> void:
	_states[value.type()] = value

func _enterState(type : StringName) -> void:
	currentState = state(type)
	currentState.enter()

func _switchState(type : StringName) -> void:
	if type.is_empty():
		return

	currentState.exit()
	_enterState(type)

#endregion


#region Implementation & Virtual functions

@warning_ignore("unused_parameter")
func insertState(value : Node) -> void:
	_states[value.type()] = value

func _initialState() -> StringName:
	return StringName()


func _nextState() -> StringName:
	return StringName()

func _interruptState(type : StringName) -> StringName:
	return type

#endregion
