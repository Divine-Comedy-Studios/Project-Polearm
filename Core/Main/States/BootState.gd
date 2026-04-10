extends AppState


@export var _mainMenu : AppState = null


func _ready() -> void:
	assert(_mainMenu != null, "BootState._ready(): Main menu wasn't assigned!")

	super._ready()


#region Override functions

func _implExit() -> void:
	_sceneResource = null # Also delete the scene resource, as we only boot once


func type() -> StringName:
	return Main.Type.boot

func nextState() -> StringName:
	if not scene.readyToSwitch():
		return Main.Type.none
	if not _mainMenu.finishedLoading():
		return Main.Type.none

	return Main.Type.mainMenu

#endregion
