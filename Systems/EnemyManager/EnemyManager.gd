extends Node
class_name EnemyManager


#region Enums

enum Role {
	idle,
	flanker,
	fighter,
	ranged,
}

#endregion


#region Constants

const ROLE_STRENGTH : Array[Role] = [
	Role.fighter,
	Role.ranged,
	Role.flanker,
	Role.idle,
]

#endregion


#region Exported variables

@export_group("Combat config")
@export var IDLE_WEIGHT : float = 0.0
@export var FLANKER_WEIGHT : float = 2.0
@export var FIGHTER_WEIGHT : float = 3.0
@export var RANGED_WEIGHT : float = 2.0
@export var ANY_WEIGHT : float = 3.0

@export_group("Enemy spawn config")
@export var MINIMUM_EMPTY_RADIUS_SQUARED : float = 1.0

#endregion


#region Member variables

# Level data

var _currentEncounter : Encounter = null
var _currentEncounterScript : Object = null
var _currentWaveIdx : int = -1
var _currentEnemyIdx : int = -1


# Enemy management

var _activeEnemies : Array[BasicEnemyHandle] = [ ]

# Enemy perception

@onready var _perceptionEngine := $EnemyPerception as EnemyPerception

# Role assignment

var _roleDifficulty : ValueResource = ValueResource.new()
var _currentRoles : Dictionary[Role, int] = {
	Role.idle : 0,
	Role.flanker : 0,
	Role.ranged : 0,
	Role.fighter : 0,
}

#endregion


#region Built-in functions

func _physics_process(delta : float) -> void:
	# Reset current state

	for role in _currentRoles.keys():
		_currentRoles[role] = 0 # Pretty sure godot wouldn't pass .values() here by reference, therefore this has to be done

	_roleDifficulty.value = 0

	# Collect current information
	for enemy : BasicEnemyHandle in _activeEnemies:
		_roleDifficulty.value += _roleWeight(enemy.role())
		_currentRoles[enemy.role()] += 1

	# Update and spawn enemies

	_perceptionEngine.tick()

	if _currentEncounter:
		var currentWave := _currentEncounter.WAVES[_currentWaveIdx]
		for enemy : BasicEnemyHandle in _activeEnemies:
			enemy.tick(delta,
				_perceptionEngine.request(
					enemy.position(),
					_assignEnemyRole(currentWave.REQUIRED_ROLES, enemy.role(), enemy.availableRoles(), enemy.requestRoleChange())
				)
			)

		_spawnWaveEnemies(currentWave)
	else:
		for enemy : BasicEnemyHandle in _activeEnemies:
			enemy.tick(delta,
				_perceptionEngine.request(
					enemy.position(),
					_assignEnemyRole({ }, enemy.role(), enemy.availableRoles(), enemy.requestRoleChange())
				)
			)

#endregion


#region Public functions

func beginEncounter(encounter : Encounter) -> void:
	if _currentEncounter != null:
		push_error("EnemyManager.beginEncounter(): An encounter was started whilst another one was active! Check for incorrect behavior.")

		return
	
	_currentEncounter = encounter

	if not _currentEncounter.SCRIPT.is_empty():
		_currentEncounterScript = (load(_currentEncounter.SCRIPT) as GDScript).new()

		assert(_currentEncounterScript != null, "Invalid encounter script!")
		assert(_currentEncounterScript.has_method("begin") && _currentEncounterScript.has_method("end"),
			"EnemyManager.beginEncounter(): Encounter script needs to have begin() and end() function!")
		_currentEncounterScript.call("begin")

	_nextWave()


func register(enemy : BasicEnemyHandle) -> void:
	_activeEnemies.push_back(enemy)

func unregister(enemy : BasicEnemyHandle) -> void:
	_activeEnemies.erase(enemy)


func reset() -> void:
	_currentEncounter = null
	_currentEncounterScript = null
	_currentWaveIdx = -1
	_currentEnemyIdx = -1

	for role in _currentRoles.keys():
		_currentRoles[role] = 0
	_roleDifficulty.value = 0.0

	_perceptionEngine.reset()

#endregion


#region Private functions

# Encounter functionality

func _validateEncounters(encounter : Encounter) -> bool:
	if encounter.SPAWN_POINTS.is_empty():
		assert(false, "EnemyManager._findSpawnPosition(): Encounter has no spawn points!")

		return false

	return true


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

	_roleDifficulty.maxValue = _currentEncounter.WAVES[_currentWaveIdx].MAX_ROLE_DIFFICULTY

	_currentEnemyIdx = 0


# Enemy spawning

func _spawnWaveEnemies(currentWave : Wave) -> void:
	# Only spawn one enemy per frame instead of multiple to avoid spawn point overlapping
	if _currentEnemyIdx < currentWave.ENEMIES.size() and _activeEnemies.size() < currentWave.MAX_ENEMY_COUNT:
		if currentWave.ENEMY_POSITIONS.has(_currentEnemyIdx):
			var transform := Transform3D()
			transform.origin = currentWave.ENEMY_POSITIONS.get(_currentEnemyIdx, Vector3.ZERO)

			Globals.world.gameObjectManager.spawn(
				currentWave.ENEMIES[_currentEnemyIdx],
				transform
			)
		else:
			var spawnPos := _findSpawnPosition()
			if not spawnPos[0] as bool:
				return # The last condition will not have changed from the last time the code was there, therefore we can return

			Globals.world.gameObjectManager.spawn(
				currentWave.ENEMIES[_currentEnemyIdx],
				spawnPos[1] as Transform3D
			)

		_currentEnemyIdx += 1

	if _currentEnemyIdx == currentWave.ENEMIES.size() and _activeEnemies.size() == 0:
		_nextWave()


func _findSpawnPosition() -> Array: # [bool, Transform3D]
	var size := _currentEncounter.SPAWN_POINTS.size()

	var entities := get_tree().get_nodes_in_group("Entities")

	var startIdx := randi() % _currentEncounter.SPAWN_POINTS.size()

	for i : int in size:
		var pos := _currentEncounter.SPAWN_POINTS[(startIdx + i) % size]

		var nearestSq := INF
		for entity : Node3D in entities:
			nearestSq = minf(nearestSq, pos.distance_squared_to(entity.global_position))

		if nearestSq >= MINIMUM_EMPTY_RADIUS_SQUARED:
			return [true, Transform3D(Basis.IDENTITY, pos)]

	return [false, Transform3D.IDENTITY]


# Role assignment

func _assignEnemyRole(requiredRoles : Dictionary[EnemyManager.Role, int], currentRole : Role, availableRoles : Array[Role], requestsRoleChange : bool) -> Role:
	# Pretend enemy is not currently registered

	_roleDifficulty.value -= _roleWeight(currentRole)
	_currentRoles[currentRole] -= 1

	var newRole := _pickEnemyRole(
		requiredRoles, 
		currentRole,
		availableRoles,
		requestsRoleChange,
		_roleDifficulty.maxValue - _roleDifficulty.value # Available role points if the enemy was not registered
	)

	_currentRoles[newRole] += 1
	if newRole != currentRole:
		_roleDifficulty.value += _roleWeight(newRole)

	return newRole


func _pickEnemyRole(requiredRoles : Dictionary[EnemyManager.Role, int], currentRole : Role, availableRoles : Array[Role], requestsRoleChange : bool, budget : float) -> Role:
	if _activeEnemies.size() == 1: # The last enemy is always aggressive, so it takes the strongest role it can
		for role : Role in ROLE_STRENGTH:
			if availableRoles.has(role):
				return role

	if requestsRoleChange: # Code looks uglier this way but avoids checking this everywhere
		for role : Role in ROLE_STRENGTH:
			if (role != currentRole
				and availableRoles.has(role)
				and _currentRoles.get(role, 0) < requiredRoles.get(role, 0) # Fill required roles
				and _roleWeight(role) <= budget
			):
				return role

		for role : Role in ROLE_STRENGTH: # Take strongest role
			if (role != currentRole
				and availableRoles.has(role)
				and _roleWeight(role) <= budget
			):
				return role
	else:
		if _currentRoles.get(currentRole, 0) < requiredRoles.get(currentRole, 0): # Stay in current role
			return currentRole

		for role : Role in ROLE_STRENGTH:
			if (availableRoles.has(role)
				and _currentRoles.get(role, 0) < requiredRoles.get(role, 0) # Fill required roles
				and _roleWeight(role) <= budget
			):
				return role

		for role : Role in ROLE_STRENGTH:
			if availableRoles.has(role) and _roleWeight(role) <= budget: # Take strongest role
				return role

	return Role.idle


func _roleWeight(role : Role) -> float:
	match role:
		Role.idle:
			return IDLE_WEIGHT
		Role.flanker:
			return FLANKER_WEIGHT
		Role.fighter: # Ranged has the same value
			return FIGHTER_WEIGHT
		Role.ranged:
			return RANGED_WEIGHT
		_:
			assert(false, "EnemyManager._roleWeight(): Invalid role!")

	return 0.0

#endregion
