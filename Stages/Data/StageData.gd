@tool

extends Resource
class_name StageData


@export_group("Player")
@export var PLAYER_SPAWN_ROTATION : Vector3 = Vector3.ZERO:
	set(value):
		if Engine.is_editor_hint():
			PLAYER_SPAWN_ROTATION = value
			PLAYER_SPAWN_TRANSFORM.basis = Basis.from_euler(value)

@export var PLAYER_SPAWN_TRANSFORM : Transform3D = Transform3D.IDENTITY
