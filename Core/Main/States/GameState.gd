extends MainThreadLoadedScene


#region Imports

const MainMenuState := preload("res://Core/Main/States/MainMenuState.gd")

const Game := preload("res://Core/Game/Game.gd")

#endregion


#region Scene members

@export var _mainMenuState : AppState = null

#endregion


#region Member variables

var _saveSlot : int = -1

#endregion


#region Built-in functions

func _ready() -> void:
	assert(_mainMenuState != null, "GameState._ready(): Please assign the main menu!")

	super._ready()
	(_mainMenuState as MainMenuState).saveSlotSelected.connect(_SIG_saveFileSelected)


#region Override functions

func enter() -> void:
	super.enter()
	(scene as Game).enter(_saveSlot)

func type() -> StringName:
	return Type.game

func nextState() -> StringName:
	return (scene as Game).exitState

#endregion


#region Signal functions

func _SIG_saveFileSelected(slot : int) -> void:
	_saveSlot = slot

#endregion
