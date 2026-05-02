extends AppState


#region Scene members

@export var _mainMenu : AppState = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(_mainMenu != null, "BootState._ready(): Main menu wasn't assigned!")

	super._ready()

#endregion


#region Override functions

func type() -> StringName:
	return Type.boot

func nextState() -> StringName:
	if not scene.finished():
		return Type.none

	return Type.mainMenu


func delayedExit() -> void:
	_unload()
	_sceneResource = null # Also delete the scene resource, as we only boot once

#endregion
