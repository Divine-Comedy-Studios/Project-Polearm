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


#region Helper classes

class RoleState extends RefCounted:
	var role : Role = Role.idle

	var requestsChange : bool = false
	var holdTimer : float = 0.0

	func _init(role_ : Role) -> void:
		role = role_
	
	func canChangeRoles(role_ : Role) -> bool:
		return holdTimer <= 0.0 and role != role_

#endregion


#region Constants

const ROLE_STRENGTH : Array[Role] = [
	Role.fighter,
	Role.ranged,
	Role.flanker,
]

#endregion


#region Exported variables

@export_group("Role config")
@export var IDLE_WEIGHT : float = 0.0
@export var FLANKER_WEIGHT : float = 2.0
@export var FIGHTER_WEIGHT : float = 3.0
@export var RANGED_WEIGHT : float = 2.0

@export_group("Role assignment config")
@export var ROLE_HOLD_TIME : float = 2.0

@export_group("Enemy spawn config")
@export var MINIMUM_EMPTY_RADIUS_SQUARED : float = 2

#endregion


#region Member variables

# Level data

var _currentEncounter : Encounter = null
var _currentEncounterScript : Object = null
var _currentWaveIdx : int = -1
var _currentEnemyIdx : int = -1


# Enemy management

var _activeEnemyStates : Dictionary[BasicEnemy, RoleState] = { }

# Enemy perception

@onready var _perceptionEngine := $EnemyPerception as EnemyPerception

# Role assignment

var _roleDifficulty : ValueResource = ValueResource.new()

var _maxRoleDifficulty : float = 0.0
var _roleDifficultyRandom : float = 0.0

#endregion


#region Built-in functions

func _ready() -> void:
	if Globals.enemyManager != null:
		push_error("EnemyManager._ready(): Enemy manager has already been initialized once!")
		return

	Globals.enemyManager = self


func _physics_process(delta : float) -> void:
	_perceptionEngine.tick()

	_roleDifficulty.maxValue = _maxRoleDifficulty + randf_range(-_roleDifficultyRandom, _roleDifficultyRandom)

	if _currentEncounter:
		var currentWave := _currentEncounter.WAVES[_currentWaveIdx]

		_planRoles(delta, currentWave.REQUIRED_ROLES)
		_tickEnemies(delta)

		_spawnWaveEnemies(currentWave)
	else:
		_planRoles(delta, { })
		_tickEnemies(delta)

#endregion


#region Public functions

func beginEncounter(encounter : Encounter, script : EncounterScript) -> void:
	if _currentEncounter != null:
		push_error("EnemyManager.beginEncounter(): An encounter was started whilst another one was active! Check for incorrect behavior.")

		return
	
	_currentEncounter = encounter

	if script:
		_currentEncounterScript = script
		_currentEncounterScript.begin()

	_nextWave()


func register(enemy : BasicEnemy) -> void:
	_activeEnemyStates[enemy] = RoleState.new(enemy.role())

func unregister(enemy : BasicEnemy) -> void:
	_activeEnemyStates.erase(enemy)


func reset() -> void:
	_currentEncounter = null
	_currentEncounterScript = null
	_currentWaveIdx = -1
	_currentEnemyIdx = -1

	_roleDifficulty.value = 0.0

	_perceptionEngine.reset()

#endregion


#region Private functions

# Enemy updates

func _tickEnemies(delta : float) -> void:
	for enemy : BasicEnemy in _activeEnemyStates.keys():
		enemy.tick(delta, _perceptionEngine.request(enemy.position(), _activeEnemyStates[enemy].role))


# Encounter functionality

func _endEncounter() -> void:
	if _currentEncounterScript:
		_currentEncounterScript.end()

	_currentEncounterScript = null
	_currentEncounter = null
	_currentWaveIdx = -1
	_currentEnemyIdx = -1

func _nextWave() -> void:
	if _currentEncounter == null:
		assert(false, "EnemyManager.nextWave(): Called whilst no encounter is currently active!")

		return

	# Increment current wave index

	_currentWaveIdx += 1
	if _currentWaveIdx >= _currentEncounter.WAVES.size():
		_endEncounter()

		return
	
	var currentWave := _currentEncounter.WAVES[_currentWaveIdx]

	_maxRoleDifficulty = currentWave.MAX_ROLE_DIFFICULTY
	_roleDifficulty.maxValue = _maxRoleDifficulty
	_roleDifficultyRandom = currentWave.ROLE_DIFFICULTY_RANDOMIZATION

	_currentEnemyIdx = 0


# Enemy spawning

func _spawnWaveEnemies(currentWave : Wave) -> void:
	# Only spawn one enemy per frame instead of multiple to avoid spawn point overlapping
	if _currentEnemyIdx < currentWave.ENEMIES.size() and _activeEnemyStates.size() < currentWave.MAX_ENEMY_COUNT:
		if currentWave.ENEMY_POSITIONS.has(_currentEnemyIdx):
			var transform := Transform3D()
			transform.origin = currentWave.ENEMY_POSITIONS.get(_currentEnemyIdx, Vector3.ZERO)

			Globals.gameObjectManager.spawn(
				currentWave.ENEMIES[_currentEnemyIdx],
				transform
			)
		else:
			var spawnPos := _findSpawnPosition()
			if not spawnPos[0] as bool:
				return # The last condition will not have changed from the last time the code was there, therefore we can return

			Globals.gameObjectManager.spawn(
				currentWave.ENEMIES[_currentEnemyIdx],
				spawnPos[1] as Transform3D
			)

		_currentEnemyIdx += 1

	if _currentEnemyIdx == currentWave.ENEMIES.size() and _activeEnemyStates.size() == 0:
		_nextWave()

func _findSpawnPosition() -> Array: # [bool, Transform3D]
	var size := _currentEncounter.SPAWN_POINTS.size()

	var entities := get_tree().get_nodes_in_group("Entities")

	var startIdx := randi() % _currentEncounter.SPAWN_POINTS.size()

	for i : int in size:
		var pos := _currentEncounter.SPAWN_POINTS[(startIdx + i) % size]

		var nearestSq := INF
		for entity : Node3D in entities:
			nearestSq = minf(nearestSq, PPUtil.Math.toFlatVec2(pos).distance_squared_to(PPUtil.Math.toFlatVec2(entity.global_position)))

		if nearestSq >= MINIMUM_EMPTY_RADIUS_SQUARED:
			return [true, Transform3D(Basis.IDENTITY, pos)]

	return [false, Transform3D.IDENTITY]


# Role assignment

func _planRoles(delta : float, requiredRoles : Dictionary[EnemyManager.Role, int]) -> void:
	# The last enemy should always be aggressive, so it takes the strongest role it can
	# Technically, the role difficulty could limit the last enemy to a low raking role,
	# but what is a weapon in the hands of one who shall not use it
	if _activeEnemyStates.size() ==	1:
		for role : Role in ROLE_STRENGTH:
			var enemy : BasicEnemy = _activeEnemyStates.keys()[0]
			if enemy.availableRoles().has(role):
				_activeEnemyStates[enemy].role = role

				return

	_updateRoleState(delta)

	var randomizedKeys :=_activeEnemyStates.keys().duplicate()
	randomizedKeys.shuffle()

	_fillRequiredRoles(randomizedKeys, requiredRoles)
	_promoteEnemies(randomizedKeys)


func _updateRoleState(delta : float) -> void:
	_roleDifficulty.value = 0
	for enemy : BasicEnemy in _activeEnemyStates.keys():
		var roleState := _activeEnemyStates[enemy]

		roleState.holdTimer -= delta
		roleState.requestsChange = roleState.holdTimer <= 0.0 and enemy.requestRoleChange()

		_roleDifficulty.value += _roleWeight(roleState.role)

func _fillRequiredRoles(randomizedKeys : Array[BasicEnemy], requiredRoles : Dictionary[EnemyManager.Role, int]) -> void:
	for role : Role in ROLE_STRENGTH:
		var requestedCount : int = requiredRoles.get(role, 0.0)
		var weight := _roleWeight(role)

		var enterCandidates : Array[BasicEnemy] = [ ]
		var exitCandidates : Array[BasicEnemy] = [ ]
		var stayCandidates : Array[BasicEnemy] = [ ]

		# First, we query all enemies and see what we can do about them
		for enemy : BasicEnemy in randomizedKeys:
			var roleState := _activeEnemyStates[enemy]

			if roleState.role == role:
				if roleState.requestsChange:
					exitCandidates.push_back(enemy)
				elif roleState.holdTimer <= 0.0: # These enemies can be taken for role swap, but won't be prefered
					stayCandidates.push_back(enemy)
				else: # For all enemies which will definetly remain in this role, they are simply registered
					requestedCount -= 1
			elif roleState.requestsChange and enemy.availableRoles().has(role):
				enterCandidates.push_back(enemy)

		# We swap roles with whoever needs or can take it
		requestedCount -= _swapEnemyRoles(enterCandidates, exitCandidates, role)
		requestedCount -= _swapEnemyRoles(enterCandidates, stayCandidates, role)

		# Then all remaining enemies are registered
		for enemy : BasicEnemy in stayCandidates:
			requestedCount -= 1
		
		# All remaining candidates get demoted
		for enemy : BasicEnemy in exitCandidates:
			var roleState := _activeEnemyStates[enemy]
			var currentWeight := _roleWeight(roleState.role)

			for exitRole : Role in ROLE_STRENGTH:
				var exitWeight := _roleWeight(exitRole)

				if _fitsRoleDifficulty(exitWeight, currentWeight):
					_assignEnemyRole(roleState, exitRole, currentWeight, exitWeight)

					continue
			
			requestedCount -= 1

		# If we have surplus roles left over, we see which enemy we can get
		while requestedCount > 0:
			var candidate := _roleCandidate(randomizedKeys, role, weight)
			if candidate[0] == null:
				break

			# If we find a candidate, assign the role
			_assignEnemyRole(candidate[0], role, candidate[1], weight)
			requestedCount -= 1

func _promoteEnemies(randomizedKeys : Array[BasicEnemy]) -> void:
	# We loop trhough all enemies by the inverse of the role strength to promote any enemies left
	for i in range(ROLE_STRENGTH.size()):
		var role := ROLE_STRENGTH[-i - 1]

		for enemy : BasicEnemy in randomizedKeys:
			var roleState := _activeEnemyStates[enemy]
			var weight := _roleWeight(role)
			var currentWeight := _roleWeight(roleState.role)

			if (enemy.availableRoles().has(role) and
				roleState.canChangeRoles(role) and # Enemy can change to current role
				currentWeight < weight and # Enemy has a worse role than the current one
				_fitsRoleDifficulty(weight, currentWeight)
			):
				_assignEnemyRole(roleState, role, currentWeight, weight)


func _swapEnemyRoles(enterCandidates : Array[BasicEnemy], exitCandidates : Array[BasicEnemy], role : Role) -> int:
	var count := 0
	while enterCandidates.size() > 0:
		if exitCandidates.size() == 0:
			break

		var enterCandidateState := _activeEnemyStates[enterCandidates[enterCandidates.size() - 1]]
		var enterCandidateRole := enterCandidateState.role

		var exitCandidate := exitCandidates[exitCandidates.size() - 1]
		if not exitCandidate.availableRoles().has(enterCandidateRole):
			exitCandidates.pop_back()

			continue

		_assignEnemyRole(_activeEnemyStates[exitCandidate], enterCandidateRole, 0.0, 0.0) # Hack to avoid role weight calculation as roles are only swapped
		_assignEnemyRole(enterCandidateState, role, 0.0, 0.0)

		enterCandidates.pop_back()
		exitCandidates.pop_back()

		count += 1

	return count

func _assignEnemyRole(roleState : RoleState, role : Role, currentWeight : float, newWeight : float) -> void:
	roleState.role = role
	roleState.holdTimer = ROLE_HOLD_TIME
	_roleDifficulty.value = _roleDifficulty.value + newWeight - currentWeight


func _roleCandidate(randomizedKeys : Array[BasicEnemy], role : Role, weight : float) -> Array:
	var best : RoleState = null
	var bestWeight : float = INF

	for enemy : BasicEnemy in randomizedKeys:
		var roleState := _activeEnemyStates[enemy]
		var currentWeight := _roleWeight(roleState.role)

		if (roleState.canChangeRoles(role) and # Enemy wants can change roles
			enemy.availableRoles().has(role) and # Enemy can take the current role
			(best == null or bestWeight > currentWeight) and # Enemy is a better candidate than the current, i.e. has a worse role
			_fitsRoleDifficulty(weight, currentWeight)
		):
			best = roleState
			bestWeight = currentWeight

	return [best, bestWeight]


func _fitsRoleDifficulty(targetWeight : float, currentWeight : float) -> bool:
	return _roleDifficulty.value + targetWeight - currentWeight <= _roleDifficulty.maxValue

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
