extends MainThreadLoadedScene


#region Imports

const MainMenu := preload("res://Interfaces/Menus/MainMenu/MainMenu.gd")

#endregion


#region Override functions

func type() -> StringName:
	return Type.mainMenu

func nextState() -> StringName:
	return (scene as MainMenu).exit()

#endregion
