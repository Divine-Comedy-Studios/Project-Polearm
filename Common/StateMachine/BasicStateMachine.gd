@warning_ignore_start("unused_parameter")

extends Node
class_name BasicStateMachine


#region Member variables

var _states : Dictionary[StringName, BasicState] = { }
var currentState : BasicState = null

#endregion


#region Public functions

func init() -> void:
	_states.get_or_add(BasicState.NONE_TYPE, BasicState.NONE)

	for child in get_children():
		_implStateInit(child)

	_enterState(_initialState())


func update() -> void:
	_switchState(_nextState())

func interrupt(type : StringName) -> void:
	_switchState(_interruptState(type))


func insertAction(value : BasicState) -> void: insertState(value)
func insertState(value : BasicState) -> void:
	_states[value.type()] = value

func action(type : StringName) -> BasicState: return state(type)
func state(type : StringName) -> BasicState:
	return _states.get(type, BasicState.NONE) as BasicState

#endregion


#region Private functions

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

func _implStateInit(child : Node) -> void:
	pass

func _initialState() -> StringName:
	return StringName()


func _nextState() -> StringName:
	return StringName()

func _interruptState(type : StringName) -> StringName:
	return type

#endregion
