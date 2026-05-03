extends AppState


#region Imports

const Game := preload("res://Core/Game/Game.gd")

#endregion


#region Scene members

@onready var pauseMenu := $PauseMenu as InterfaceStateMachine

#endregion


#region Built-in functions

func _ready() -> void:
	pauseMenu.hide()

#endregion


#region Override functions

func enter() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	pauseMenu.show()
	pauseMenu.enter()

func exit() -> void:
	pauseMenu.hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func type() -> StringName:
	return Type.paused

func nextState() -> StringName:
	var exitState := pauseMenu.exit()
	if exitState == Type.none:
		return Type.none
	if exitState == Type.mainMenu:
		(stateMachine as Game).exitState = exitState
		return Type.none

	return exitState

#endregion
