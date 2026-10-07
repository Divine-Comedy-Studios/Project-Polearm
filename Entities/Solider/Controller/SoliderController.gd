extends BasicEnemyController
class_name SoliderController

# Behavior per role:
# - idle: stands still, facing the player
# - flanker: walks to a spot around the player which is as far away from the other enemies as possible
# - fighter (the attacker): rushes the player and attacks, then asks to give up the role so another enemy can take over
#
# Scene setup: AVAILABLE_ROLES needs to contain idle, flanker and fighter.
# @todo Assumes the nodes in the "Enemies" group are the moving bodies of the enemies (the entities).


#region Helper structures

# Input data container
class Data extends BasicEnemyController.Data:
	var speedMultiplier : float = 1.0 # Per-enemy random speed variation

	func reset() -> void:
		super.reset()

		speedMultiplier = 1.0

#endregion


#region Constants

# A flank spot is at least this fraction of the flank distance away from the player, so a flanker does not end up in melee range
const MIN_FLANK_RADIUS_FRACTION : float = 0.5

#endregion


#region Exported variables

@export_group("Combat")
@export var ATTACK_RANGE : float = 1.8
## Distance at which the enemy stops running towards the player. Should be smaller than ATTACK_RANGE.
@export var STOP_DISTANCE : float = 1.4
## Random time (seconds) between the end of an attack and the next one.
@export var ATTACK_COOLDOWN : Vector2 = Vector2(1.0, 3.0)

@export_group("Flanking")
## Flankers pick a spot within this radius around the player.
@export var FLANK_DISTANCE : float = 8.0
## Distance to the spot at which the flanker has arrived.
@export var FLANK_STOP_DISTANCE : float = 0.5
## Fraction of the full speed at which flankers move, which makes them walk instead of run.
@export_range(0.0, 1.0) var FLANK_MOVE_MAGNITUDE : float = 0.4
## Random time (seconds) before the flank spot is picked again.
@export var FLANK_REPICK_TIME : Vector2 = Vector2(2.0, 5.0)
## Amount of random spots to choose the best one from.
@export var FLANK_CANDIDATE_COUNT : int = 12

@export_group("Randomness")
## Each enemy's speed is multiplied by a random value in [1 - variance, 1 + variance].
@export_range(0.0, 0.9) var SPEED_VARIANCE : float = 0.25

#endregion


#region Member variables

var _speedMultiplier : float = 1.0

var _cooldownTimer : float = 0.0 # INF whilst attacking

var _lastRole : EnemyManager.Role = EnemyManager.Role.idle
var _flankOffset : Vector2 = Vector2.ZERO # Spot to flank from, relative to the player
var _flankTimer : float = 0.0

#endregion


#region Built-in functions

func _init() -> void:
	intents = Data.new()

#endregion


#region Public functions

func beforeAttack() -> void:
	_cooldownTimer = INF

func afterAttack() -> void:
	_cooldownTimer = randf_range(ATTACK_COOLDOWN.x, ATTACK_COOLDOWN.y)

	# Give the attacker role to someone else
	requestRoleChange = true

#endregion


#region Implementation functions

func _tickAndTarget(delta : float, distance : float, _toTarget : Vector2, perceptionData : EnemyPerception.Data) -> Vector3:
	var flatPosition := PPUtil.Math.toFlatVec2(entity.global_position)
	var flatTarget := PPUtil.Math.toFlatVec2(perceptionData.target)

	# The direction towards the player is worked out here instead of using the one which was passed in,
	# as that one points from the player to the entity
	var toPlayer := (flatTarget - flatPosition).normalized()
	intents.direction = toPlayer

	_cooldownTimer = maxf(_cooldownTimer - delta, 0.0) # Stays INF whilst attacking

	match currentRole:
		EnemyManager.Role.flanker:
			_tickFlank(delta, flatPosition, flatTarget)
		EnemyManager.Role.fighter:
			_tickAttack(distance, flatPosition, flatTarget, toPlayer, perceptionData)
		_:
			pass # Idle, stand and face the player

	_lastRole = currentRole

	return perceptionData.target


func _implReset() -> void:
	_speedMultiplier = randf_range(1.0 - SPEED_VARIANCE, 1.0 + SPEED_VARIANCE)
	_cooldownTimer = 0.0

	_lastRole = EnemyManager.Role.idle
	_flankOffset = Vector2.ZERO
	_flankTimer = 0.0

#endregion


#region Private functions

func _tickFlank(delta : float, flatPosition : Vector2, flatTarget : Vector2) -> void:
	# Pick a spot right away when becoming a flanker, and every so often after that
	_flankTimer -= delta
	if currentRole != _lastRole or _flankTimer <= 0.0:
		_flankOffset = _pickFlankOffset(flatTarget)
		_flankTimer = randf_range(FLANK_REPICK_TIME.x, FLANK_REPICK_TIME.y)

	# The spot is relative to the player, so it follows them around
	_moveTo(flatTarget + _flankOffset, flatPosition, FLANK_STOP_DISTANCE, FLANK_MOVE_MAGNITUDE)


func _tickAttack(distance : float, flatPosition : Vector2, flatTarget : Vector2, toPlayer : Vector2, perceptionData : EnemyPerception.Data) -> void:
	if _cooldownTimer == INF:
		return # In the middle of an attack

	if _cooldownTimer > 0.0:
		requestRoleChange = true # Cooling down, so someone else should be the attacker

	# Rush the player at full speed, no matter how far away
	_moveTo(flatTarget, flatPosition, STOP_DISTANCE, 1.0)

	if (_cooldownTimer <= 0.0 and perceptionData.detected
		and _canAttack(distance, ATTACK_RANGE, toPlayer, -entity.global_basis.z)
	):
		intents.actions.append(SoliderAction.Type.lightAttack)


# Runs to the point, and just stands there (facing the player) once it has arrived
func _moveTo(point : Vector2, flatPosition : Vector2, stopDistance : float, magnitude : float) -> void:
	var offset := point - flatPosition
	var distance := offset.length()
	if distance <= stopDistance:
		return

	intents.direction = offset / distance
	intents.magnitude = magnitude
	(intents as Data).speedMultiplier = _speedMultiplier
	intents.actions.append(SoliderAction.Type.move)


# Picks the random spot around the player which is the furthest away from all other enemies
func _pickFlankOffset(flatTarget : Vector2) -> Vector2:
	var others : Array[Vector2] = []
	for node : Node in get_tree().get_nodes_in_group("Enemies"):
		if node != entity and node is Node3D:
			others.push_back(PPUtil.Math.toFlatVec2((node as Node3D).global_position))

	var bestOffset := Vector2.ZERO
	var bestScore := -INF
	for i : int in FLANK_CANDIDATE_COUNT:
		var radius := FLANK_DISTANCE * randf_range(MIN_FLANK_RADIUS_FRACTION, 1.0)
		var offset := Vector2.from_angle(randf() * TAU) * radius

		# How far the closest other enemy is from this spot
		var score := INF
		for other : Vector2 in others:
			score = minf(score, (flatTarget + offset).distance_to(other))

		# Without other enemies every spot is as good as the other, so the first random one is taken
		if score > bestScore:
			bestScore = score
			bestOffset = offset

	return bestOffset

#endregion
