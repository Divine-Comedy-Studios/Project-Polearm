extends GameObject
class_name Entity


#region Scene members

@export_group("Scene members")
@export var actionManager : EntityActionManager = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(actionManager != null, "Entity._ready(): Action manager not assigned!")

#endregion


#region Public functions

func spawn(payload : Variant) -> void:
	assert(payload is Transform3D, "PlayerHandle.spawn(): Wrong spawn data type!")

	_spawn(payload)

	actionManager.entity.global_transform = payload as Transform3D

#endregion


#region Private functions

@warning_ignore("unused_parameter")
func _spawn(payload : Variant) -> void:
	pass

#endregion
