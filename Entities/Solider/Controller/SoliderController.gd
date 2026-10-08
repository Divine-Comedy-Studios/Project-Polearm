extends BasicEnemyController

class_name SoliderController


#region Helper structures

class Data extends BasicEnemyController.Data:

	var speed : float = 0.0
	var minSpeed : float = 0.0
	var maxSpeed : float = 0.0

	func reset() -> void:

		super.reset()

		speed = 0.0

#endregion


#region Constants

const MIN_FLANK_RADIUS_FRACTION : float = 0.5

#endregion


#region Exported variables

@export_group("Movement")

@export var MIN_SPEED : float = 2.0

@export var MAX_SPEED : float = 5.5


@export_group("Combat")

@export var ATTACK_RANGE : float = 1.8

@export var STOP_DISTANCE : float = 1.4

@export var ATTACK_COOLDOWN : Vector2 = Vector2(1.0, 3.0)


@export_group("Flanking")

@export var FLANK_DISTANCE : float = 8.0

@export var FLANK_STOP_DISTANCE : float = 0.5

@export var FLANK_LOOKAHEAD : float = 2.0

@export_range(0.0, 1.0) var FLANK_MOVE_MAGNITUDE : float = 0.0

@export var FLANK_REPICK_TIME : Vector2 = Vector2(2.0, 5.0)

@export var FLANK_CANDIDATE_COUNT : int = 12


@export_group("Randomness")

@export_range(0.0, 0.9) var SPEED_VARIANCE : float = 0.25

#endregion


@onready var label := $"../Model/Label3D" as Label3D

#region Member variables

var _speedMultiplier : float = 1.0

var _cooldownTimer : float = 0.0

var _lastRole : EnemyManager.Role = EnemyManager.Role.idle

var _flankOffset : Vector2 = Vector2.ZERO

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

	_cooldownTimer = randf_range(
		ATTACK_COOLDOWN.x,
		ATTACK_COOLDOWN.y
	)

	requestRoleChange = true

#endregion


#region Implementation functions

func _tickAndTarget(
	delta : float,
	distance : float,
	toTarget : Vector2,
	perceptionData : EnemyPerception.Data
) -> Vector3:
	if currentRole == EnemyManager.Role.idle:
		label.text = "idle"
	elif currentRole == EnemyManager.Role.fighter:
		label.text = "fighter"
	else:
		label.text = "flanker"

	var flatPosition := PPUtil.Math.toFlatVec2(entity.global_position)

	var flatTarget := PPUtil.Math.toFlatVec2(perceptionData.targetPos)

	_cooldownTimer = maxf(_cooldownTimer - delta, 0.0)

	match currentRole:

		EnemyManager.Role.flanker:
			_tickFlank(delta, flatPosition, flatTarget)

		EnemyManager.Role.fighter:
			_tickAttack(
				distance,
				flatPosition,
				flatTarget,
				toTarget,
				perceptionData
			)

		_:
			pass

	_lastRole = currentRole

	return perceptionData.targetPos


func _implReset() -> void:

	_speedMultiplier = randf_range(
		1.0 - SPEED_VARIANCE,
		1.0 + SPEED_VARIANCE
	)

	_cooldownTimer = 0.0

	_lastRole = EnemyManager.Role.idle

	_flankOffset = Vector2.ZERO

	_flankTimer = 0.0

	(intents as Data).minSpeed = MIN_SPEED
	(intents as Data).maxSpeed = MAX_SPEED

#endregion


#region Private functions

func _tickFlank(
	delta : float,
	flatPosition : Vector2,
	flatTarget : Vector2
) -> void:

	# Pick a new flank position when becoming a flanker,
	# or after the current position has been held for a while.

	_flankTimer -= delta

	if currentRole != _lastRole or _flankTimer <= 0.0:

		_flankOffset = _pickFlankOffset(
			flatTarget,
			_flankOffset
		)

		_flankTimer = randf_range(
			FLANK_REPICK_TIME.x,
			FLANK_REPICK_TIME.y
		)

	var fromTarget := flatPosition - flatTarget

	var radius := fromTarget.length()

	# Avoid unstable angular calculations when directly on the player.
	if radius <= 0.001:

		_moveTo(
			flatTarget,
			flatPosition,
			0.0,
			FLANK_MOVE_MAGNITUDE
		)

		return

	var currentAngle := fromTarget.angle()

	var targetRadius := _flankOffset.length()

	var targetAngle := _flankOffset.angle()

	var angleToTarget := angle_difference(
		currentAngle,
		targetAngle
	)

	var arcDistance := absf(angleToTarget) * radius

	# We have reached the flank position.
	if (
		arcDistance <= FLANK_STOP_DISTANCE
		and absf(radius - targetRadius) <= FLANK_STOP_DISTANCE
	):

		# Stop moving but continue facing the player.
		intents.direction = flatTarget - flatPosition
		intents.direction = intents.direction.normalized()

		intents.magnitude = 0.0
		(intents as Data).speed = 0.0

		intents.actions.append(SoliderAction.Type.move)

		return

	# Determine which direction around the player we need to travel.
	var directionSign := signf(angleToTarget)

	if is_zero_approx(directionSign):

		directionSign = 1.0

	# Convert lookahead distance into an angular offset.
	var lookaheadAngle := minf(
		absf(angleToTarget),
		FLANK_LOOKAHEAD / maxf(radius, 0.001)
	)

	var desiredAngle := currentAngle + directionSign * lookaheadAngle

	# Move toward the desired radius at the same time.
	var desiredRadius := move_toward(
		radius,
		targetRadius,
		FLANK_LOOKAHEAD
	)

	var desiredPoint := (
		flatTarget
		+ Vector2.from_angle(desiredAngle) * desiredRadius
	)

	_moveTo(
		desiredPoint,
		flatPosition,
		0.0,
		FLANK_MOVE_MAGNITUDE
	)


func _tickAttack(
	distance : float,
	flatPosition : Vector2,
	flatTarget : Vector2,
	toTarget : Vector2,
	perceptionData : EnemyPerception.Data
) -> void:

	if _cooldownTimer == INF:

		return

	if _cooldownTimer > 0.0:

		requestRoleChange = true

	_moveTo(
		flatTarget,
		flatPosition,
		STOP_DISTANCE,
		1.0
	)

	if (
		_cooldownTimer <= 0.0
		and perceptionData.detected
		and _canAttack(
			distance,
			ATTACK_RANGE,
			toTarget,
			-entity.global_basis.z
		)
	):

		intents.actions.append(
			SoliderAction.Type.lightAttack
		)


func _moveTo(
	point : Vector2,
	flatPosition : Vector2,
	stopDistance : float,
	magnitude : float
) -> void:

	var offset := point - flatPosition

	var distance := offset.length()

	if distance <= stopDistance:

		intents.magnitude = 0.0
		(intents as Data).speed = 0.0

		return

	intents.direction = offset / distance

	intents.magnitude = magnitude

	(intents as Data).speed = clampf(
		lerpf(
			MIN_SPEED,
			MAX_SPEED,
			magnitude
		) * _speedMultiplier,
		MIN_SPEED,
		MAX_SPEED
	)

	intents.actions.append(
		SoliderAction.Type.move
	)


func _pickFlankOffset(
	flatTarget : Vector2,
	currentOffset : Vector2
) -> Vector2:

	var others : Array[Vector2] = []

	for node : Node in get_tree().get_nodes_in_group("Enemies"):

		if node != entity and node is Node3D:

			others.push_back(
				PPUtil.Math.toFlatVec2(
					(node as Node3D).global_position
				)
			)

	var bestOffset := Vector2.ZERO
	var bestScore := -INF

	# Give the current flank position a small advantage.
	# This prevents unnecessary jumps between equivalent positions.
	var currentScore := -INF

	if not currentOffset.is_zero_approx():

		currentScore = _scoreFlankOffset(
			flatTarget,
			currentOffset,
			others
		)

	for i : int in FLANK_CANDIDATE_COUNT:

		var radius := FLANK_DISTANCE * randf_range(
			MIN_FLANK_RADIUS_FRACTION,
			1.0
		)

		var offset := Vector2.from_angle(
			randf() * TAU
		) * radius

		var score := _scoreFlankOffset(
			flatTarget,
			offset,
			others
		)

		if score > bestScore:

			bestScore = score
			bestOffset = offset

	# Keep the current position if it is already reasonably good.
	if currentScore >= bestScore * 0.9:

		return currentOffset

	return bestOffset


func _scoreFlankOffset(
	flatTarget : Vector2,
	offset : Vector2,
	others : Array[Vector2]
) -> float:

	if others.is_empty():

		return 0.0

	var position := flatTarget + offset

	var score := INF

	for other : Vector2 in others:

		score = minf(
			score,
			position.distance_to(other)
		)

	return score

#endregion
