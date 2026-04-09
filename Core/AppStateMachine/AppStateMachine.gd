extends BasicStateMachine
class_name AppStateMachine


#region Built-in functions

func _ready() -> void:
	init()

func _process(_delta : float) -> void:
	update()

#endregion


#region Override functions

func _implStateInit(child : Node) -> void:
	if child is AppState:
		insertState(child)


func _nextState() -> StringName:
	return currentState.nextState()

#endregion
