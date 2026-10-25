@tool

extends EventTrigger
class_name EncounterTrigger


#region Exported variables

@export var ENCOUNTER : Encounter = null
@export var SCRIPT : EncounterScript = null

@export var SPAWN_POINT_PARENT : Node3D = null
@export var FIXED_SPAWN_POINT_PARENT : Node3D = null


@warning_ignore("unused_private_class_variable")
@export_tool_button("Set spawn points") var _setspfunc = _updateSpawnPoints
@warning_ignore("unused_private_class_variable")
@export_tool_button("Set fixed spawn points") var _setfspfunc = _updateFixedSpawnPoints

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

func _updateSpawnPoints() -> void:
	if ENCOUNTER == null or SPAWN_POINT_PARENT == null:
		return

	var spawnPoints : Array[Vector3] = []

	for child in SPAWN_POINT_PARENT.get_children():
		if child is Node3D:
			spawnPoints.append(child.global_position)

	ENCOUNTER.SPAWN_POINTS = spawnPoints

	if not ENCOUNTER.resource_path.is_empty():
		ResourceSaver.save(ENCOUNTER, ENCOUNTER.resource_path)
	

func _updateFixedSpawnPoints() -> void:
	if ENCOUNTER == null or FIXED_SPAWN_POINT_PARENT == null:
		return
	
	for wavePoints : Node in FIXED_SPAWN_POINT_PARENT.get_children():
		if not wavePoints is Node3D or not wavePoints.name.is_valid_int():
			continue

		var idx := wavePoints.name.to_int()
		if idx < 0 or idx >= ENCOUNTER.WAVES.size():
			continue

		var spawnPoints : Dictionary[int, Vector3] = { }
		var wave := ENCOUNTER.WAVES[idx]

		for child : Node in wavePoints.get_children():
			if not child is Node3D or not child.name.is_valid_int():
				continue
			
			var enemyIdx := child.name.to_int()
			if idx < 0 or enemyIdx >= wave.ENEMIES.size():
				continue

			spawnPoints[enemyIdx] = (child as Node3D).global_position

		wave.ENEMY_POSITIONS = spawnPoints

#endregion
