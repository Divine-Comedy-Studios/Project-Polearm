extends AppState
class_name BootState


@export var _mainMenu : MainMenuState = null


func _ready() -> void:
	assert(_mainMenu != null, "BootState._ready(): Main menu wasn't assigned!")

	super._ready()


#region Override functions

func _implExit() -> void:
	_sceneResource = null # Also delete the scene resource, as we only boot once


func type() -> int:
	return Main.Type.boot

func nextState() -> int:
	if not scene.readyToSwitch():
		return Main.Type.none
	if not _mainMenu.finishedLoading():
		return Main.Type.none

	return Main.Type.mainMenu

#endregion
