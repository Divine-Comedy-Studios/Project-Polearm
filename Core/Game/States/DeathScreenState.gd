extends GameState


#region Imports

const Game := preload("res://Core/Game/Game.gd")

#endregion


#region Scene members

@onready var deathMenu := $DeathMenu as InterfaceStateMachine

#endregion


#region Built-in functions

func _ready() -> void:
	deathMenu.hide()

#endregion


#region Override functions

func enter() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	deathMenu.show()
	deathMenu.enter()

func exit() -> void:
	deathMenu.hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func type() -> StringName:
	return Type.gameOver

func nextState() -> StringName:
	var exitState := deathMenu.exit()
	if exitState == Type.mainMenu:
		(stateMachine as Game).exitState = exitState
		return Type.none
	if exitState == Type.world:
		payload = Globals.world.currentStageType

		Globals.world.reset()

	return exitState

#endregion
