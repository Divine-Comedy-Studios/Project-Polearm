@tool

extends EventTrigger
class_name EncounterTrigger


#region Exported variables

@export var ENCOUNTER : Encounter = null
@export var SCRIPT : EncounterScript = null

@export var SPAWN_POINT_PARENT : Node3D:
	set(value):
		if Engine.is_editor_hint():
			SPAWN_POINT_PARENT = value
			_updateSpawnPoints(value)

#endregion


#region Built-in functions

func _ready() -> void:
	super._ready()

	if not Engine.is_editor_hint():
		if ENCOUNTER.SPAWN_POINTS.is_empty():
			assert(false, "EnemyManager._findSpawnPosition(): Encounter has no spawn points!")

		enable()

func trigger(node : Node3D) -> void:
	if node.is_in_group("Player"):
		disable()

		Globals.enemyManager.beginEncounter(ENCOUNTER, SCRIPT)

#endregion


#region Private functions

func _updateSpawnPoints(spawnPointParent : Node3D) -> void:
	if ENCOUNTER == null or spawnPointParent == null:
		return

	var spawn_points: Array[Vector3] = []

	for child in spawnPointParent.get_children():
		if child is Node3D:
			spawn_points.append(child.global_position)

	ENCOUNTER.SPAWN_POINTS = spawn_points

	if not ENCOUNTER.resource_path.is_empty():
		ResourceSaver.save(ENCOUNTER, ENCOUNTER.resource_path)

#endregion
