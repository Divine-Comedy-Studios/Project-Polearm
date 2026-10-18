extends Node3D
class_name Entity


#region Helper classes

class SpawnData extends Resource:
	@export var TRANSFORM : Transform3D = Transform3D.IDENTITY

#endregion


#region Scene members

@export_group("Scene members")
@export var actionManager : EntityActionManager = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(actionManager != null, "Entity._ready(): Action manager not assigned!")

#endregion


#region Public functions

func spawn(spawnTransform : Transform3D) -> void:
	_spawn()

	actionManager.entity.global_transform = spawnTransform

#endregion


#region Private functions

func _spawn() -> void:
	pass

#endregion
