extends AppState


#region Scene members

@onready var pauseMenu := $PauseMenu as InterfaceStateMachine

#endregion


#region Built-in functions

func _ready() -> void:
	pauseMenu.hide()

#endregion


#region Override functions

func _implEnter() -> void:
	pauseMenu.show()
	pauseMenu.enter()


func delayedExit() -> void:
	pauseMenu.hide()

func type() -> StringName:
	return Type.paused

func nextState() -> StringName:
	return pauseMenu.exit()

#endregion
