extends Entity
class_name Player


#region Scene members

@export_group("Scene members")
@export var _model : FloatingBody = null
@export var _cameraManager : PlayerCameraManager = null
@export var _actionManager : PlayerActionManager = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(_model != null, "Player._ready(): Simulation model not assigned!")
	assert(_cameraManager != null,  "Player._ready(): Camera manager not assigned!")
	assert(_actionManager != null,  "Player._ready(): Action manager not assigned!")

	_cameraManager.setFollowTarget(_model)

func kill() -> void:
	_actionManager.reset()

#endregion
