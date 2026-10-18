extends Entity
class_name Player


#region Scene members

@export_group("Scene members")
@export var _cameraManager : PlayerCameraManager = null

#endregion


#region Built-in functions

func _ready() -> void:
	super._ready()

	assert(_cameraManager != null, "Player._ready(): Camera manager not assigned!")

#endregion


#region Override functions

func _spawn() -> void:
	_cameraManager.setFollowTarget(actionManager.entity)

func kill() -> void:
	actionManager.reset()

#endregion
