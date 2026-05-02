extends BasicStateMachine
class_name AppStateMachine


#region Imports

const LoadingState := preload("res://Core/AppStateMachine/Loading/LoadingState.gd")

#endregion


#region Member variables

var loadingScreen : LoadingState = null

#endregion


#region Built-in functions

func _ready() -> void:
	init()

	assert(_states.has(AppState.Type.loading), "AppStateMachine._nextState(): All application level state machines need a loading screen!")
	loadingScreen = state(AppState.Type.loading) as LoadingState

func _process(_delta : float) -> void:
	update()

#endregion


#region Override functions

func _implStateInit(child : Node) -> void:
	if child is AppState:
		child.stateMachine = self
		insertState(child)


func _nextState() -> StringName:
	var current := currentState as AppState
	var next := current.nextState()
	if next == AppState.Type.none:
		return AppState.Type.none

	var nextState := state(next) as AppState
	if not nextState.available():
		loadingScreen.requestLoad(current, nextState)
		return AppState.Type.loading

	current.delayedExit()
	return next

#endregion
