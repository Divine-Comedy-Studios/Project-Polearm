extends Node3D
class_name Entity


#region Helper classes

class SpawnData extends Resource:
	@export var TRANSFORM : Transform3D = Transform3D.IDENTITY

#endregion


#region Public functions

func spawn(spawnTransform : Transform3D) -> void:
	transform = spawnTransform

	_spawn()

#endregion


#region Private functions

func _spawn() -> void:
	pass

#endregion
