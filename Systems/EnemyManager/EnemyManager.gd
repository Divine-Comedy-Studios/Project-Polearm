extends Node
class_name EnemyManager


#region Enums

enum Role {
	inactive,
	dummy,

	fighter,
	flanker,
	circler,
	ranged,
	any,

	boss,
}

#endregion


#region Helper classes

class EnemySpawnData:
	var transform : Transform3D = Transform3D.IDENTITY

	var role : Role = Role.dummy

#endregion


#region Exported variables

@export_group("Combat config")
@export var FIGHTER_WEIGHT : float = 3.0
@export var FLANKER_WEIGHT : float = 2.0
@export var CIRCLER_WEIGHT : float = 1.0
@export var RANGED_WEIGHT : float = 1.5
@export var ANY_WEIGHT : float = 3.0

@export_group("Enemy spawn config")
@export var GAME_OBJECT_DATASET : GameObjectDataset = null

#endregion


#region Member variables

# Level data

@export_group("DEBUG")
@export var _encounters : Array[Encounter] = [ ]
var _currentEncounter : Encounter = null
var _currentEncounterScript : Object = null
var _currentWaveIdx : int = -1
var _currentEnemyIdx : int = -1


# Enemy management

var _pools : Dictionary[GameObject.Type, GameObjectPool] = { }


# Role assignment

var _roleDifficulty : IntegerResource
var _currentRoles : Dictionary[Role, bool]

#endregion


#region Built-in functions

func _ready() -> void:
	if Globals.enemyManager != null:
		push_error("EnemyManager._ready(): EnemyManager has already been initialized once!")

		return

	Globals.enemyManager = self


func _physics_process(delta : float) -> void:
	var enemyCount := 0

	for pool : GameObjectPool in _pools.values():
		for enemy : GameObject in pool.active.values():
			enemy.tick(delta) #, _perception.requestData())

			enemyCount += 1

	if _currentEncounter:
		_spawnWaveEnemies(enemyCount)

#endregion


#region Public functions

func init(stageData : StageData) -> void:
	_encounters = stageData.ENCOUNTERS

	var idx := 0
	for encounter : Encounter in _encounters:
		var trigger := EncounterTrigger.new(idx, encounter.TRIGGER_REGION)
		trigger.transform = encounter.TRANSFORM

		add_child(trigger)
		trigger.enable()

		idx += 1

func beginEncounter(index : int) -> void:
	if _currentEncounter != null:
		push_error("EnemyManager.beginEncounter(): An encounter was started whilst another one was active! Check for incorrect behavior.")

		return

	_currentEncounter = _encounters[index]

	if not _currentEncounter.SCRIPT.is_empty():
		_currentEncounterScript = (load(_currentEncounter.SCRIPT) as GDScript).new()

		assert(_currentEncounterScript != null, "Invalid encounter script!")
		assert(_currentEncounterScript.has_method("begin") && _currentEncounterScript.has_method("end"),
			"EnemyManager.beginEncounter(): Encounter script needs to have begin() and end() function!")
		_currentEncounterScript.call("begin")

	_nextWave()

#endregion


#region Private functions

func _spawnEnemy(type : GameObject.Type, transform : Transform3D) -> void:
	if not _pools.has(type):
		var pool := GameObjectPool.new(type, GAME_OBJECT_DATASET)
		_pools[type] = pool
		add_child(pool)
	
	var spawnData := EnemySpawnData.new()
	spawnData.role = _assignEnemyRole()
	spawnData.transform = transform

	_pools[type].spawn(spawnData)


func _spawnWaveEnemies(currentEnemyCount : int) -> void:
	var currentWave := _currentEncounter.WAVES[_currentWaveIdx]

	while _currentEnemyIdx < currentWave.ENEMIES.size() and currentEnemyCount < currentWave.MAX_ENEMY_COUNT:
		_spawnEnemy(
			currentWave.ENEMIES[_currentEnemyIdx],
			currentWave.ENEMY_POSITIONS.get(_currentEnemyIdx, Vector3.ZERO) if currentWave.ENEMY_POSITIONS.has(_currentEnemyIdx) else _findSpawnPosition()
		)

		_currentEnemyIdx += 1
		currentEnemyCount += 1

	if _currentEnemyIdx == currentWave.ENEMIES.size() and currentEnemyCount == 0:
		_nextWave()


func _endEncounter() -> void:
	if _currentEncounterScript:
		_currentEncounterScript.call("end")

	_currentEncounterScript = null
	_currentEncounter = null
	_currentWaveIdx = -1
	_currentEnemyIdx = 0


func _nextWave() -> void:
	if _currentEncounter == null:
		assert(false, "EnemyManager.nextWave(): Called whilst no encounter is currently active!")

		return

	# Increment current wave index

	_currentWaveIdx += 1
	if _currentWaveIdx >= _currentEncounter.WAVES.size():
		_endEncounter()

		return

	_currentEnemyIdx = 0


func _findSpawnPosition() -> Transform3D:
	return Transform3D.IDENTITY


func _assignEnemyRole() -> Role:
	return Role.inactive

#endregion
