extends MainThreadLoadedScene


#region Imports

const MainMenu := preload("res://Interfaces/Menus/MainMenu/MainMenu.gd")

#endregion


#region Signals

signal saveSlotSelected(slot : int)

#endregion


#region Override functions

func enter() -> void:
	super.enter()
	(scene as MainMenu).injectSaveSlotSignal(saveSlotSelected)


func type() -> StringName:
	return Type.mainMenu

func nextState() -> StringName:
	return (scene as MainMenu).exit()

#endregion
