extends BasicEnemyController
class_name SoliderController


#region Constants

const FLANK_POSITION_EPSILON : float = 0.5
const FLANK_STEP_ANGLE : float = 0.1

#endregion


#region Exported variables

@export_group("Combat")
@export var STOP_DISTANCE : float = 1.4
@export var ATTACK_COOLDOWN : Vector2 = Vector2(1.0, 3.0)

@export_group("Flanking")
@export var FLANK_DISTANCE : float = 8.0
@export var FLANK_RETARGET_COOLDOWN : Vector2 = Vector2(0.0, 3.0)
@export var FLANK_TARGET_CANDIDATE_COUNT : int = 12
@export_range(0.0, 0.9) var FLANK_DISTANCE_RANDOMESS : float = 0.2

#endregion


#region Member variables

var _lastRole : EnemyManager.Role = EnemyManager.Role.idle

var _cooldownTimer : float = 0.0

var _flankTarget : Vector2 = Vector2.ZERO
var _flankTargetAngle : float = 0.0
var _flankTargetRadius : float = 0.0

var _flankTimer : float = 0.0
var _flankSpeed : float = 0.0

#endregion


#region Override functions

func _tick(
	delta : float,
	perceptionData : EnemyPerception.Data
) -> void:
	var label := $"../Model/Label3D" as Label3D
	if currentRole == EnemyManager.Role.idle:
		label.text = "idle"
	elif currentRole == EnemyManager.Role.fighter:
		label.text = "fighter"
	else:
		label.text = "flanker"

	var flatPosition := PPUtil.Math.toFlatVec2(entity.global_position)
	var flatTarget := PPUtil.Math.toFlatVec2(perceptionData.targetPos)

	if _cooldownTimer > 0.0:
		if currentRole == EnemyManager.Role.flanker:
			_tickFlank(delta, flatPosition, flatTarget)

		if _cooldownTimer != INF:
			_cooldownTimer -= delta
	else:
		if currentRole == EnemyManager.Role.flanker:
			_tickFlank(delta, flatPosition, flatTarget)
		else:
			_flankTimer = 0.0 # Reset flank timer as _tickFlank expects a reset timer upon state change

			_tickAttack(flatPosition, flatTarget, perceptionData)

	_lastRole = currentRole


func _implReset() -> void:
	_lastRole = EnemyManager.Role.idle

	_cooldownTimer = 0.0

	_flankTimer = 0.0
	_flankTarget = Vector2.ZERO
	_flankSpeed = 0.0

#endregion


#region Public functions

func beforeAttack() -> void:
	_cooldownTimer = INF

func afterAttack() -> void:
	_cooldownTimer = randf_range(ATTACK_COOLDOWN.x, ATTACK_COOLDOWN.y)

	requestRoleChange = true

#endregion


#region Private functions

func _tickFlank(delta : float, flatPosition : Vector2, flatTarget : Vector2) -> void:
	_flankTimer -= delta

	if _flankTimer <= 0.0: # Pick new target and wait time until next target pick
		_flankTarget = _pickFlankTarget(flatTarget, _flankTarget)
		_flankTargetAngle = _flankTarget.angle()
		_flankTargetRadius = _flankTarget.length()

		_flankTimer = randf_range(FLANK_RETARGET_COOLDOWN.x, FLANK_RETARGET_COOLDOWN.y)
		_flankSpeed = randf_range(0.0, 1.0)

	var toTarget := flatPosition - flatTarget

	if (toTarget - _flankTarget).length_squared() < FLANK_POSITION_EPSILON:
		intents.direction = toTarget.normalized()
		intents.magnitude = 0.0

		return

	var currentRadius := toTarget.length()
	var currentAngle := toTarget.angle()
	var angleToFlankTarget := angle_difference(currentAngle, _flankTargetAngle)

	var targetAngle := currentAngle + signf(angleToFlankTarget) * minf(FLANK_STEP_ANGLE, absf(angleToFlankTarget))
	var targetPoint := Vector2.from_angle(targetAngle) * move_toward(currentRadius, _flankTargetRadius, FLANK_STEP_ANGLE)

	intents.direction = (flatTarget + targetPoint - flatPosition).normalized()
	intents.magnitude = _flankSpeed

	intents.actions.append(SoliderAction.Type.move)


func _tickAttack(flatPosition : Vector2, flatTarget : Vector2, perceptionData : EnemyPerception.Data) -> void:
	if _cooldownTimer > 0.0:
		requestRoleChange = true

	intents.magnitude = 1.0
	intents.direction = flatTarget - flatPosition

	var distance := intents.direction.length()
	intents.direction /= distance

	if distance > STOP_DISTANCE:
		intents.actions.append(SoliderAction.Type.move)

	if (_cooldownTimer <= 0.0
		and perceptionData.detected
		and _canAttack(distance, intents.direction, -entity.global_basis.z)
	):
		intents.actions.append(SoliderAction.Type.lightAttack)


func _pickFlankTarget(center : Vector2, currentTarget : Vector2) -> Vector2:
	var enemies : Array[Vector2] = []

	for node : Node in get_tree().get_nodes_in_group("Enemies"):
		if node != entity and node is Node3D:
			enemies.push_back(PPUtil.Math.toFlatVec2((node as Node3D).global_position))

	var bestScore := -INF
	var bestTarget := currentTarget

	for i : int in FLANK_TARGET_CANDIDATE_COUNT:
		# Random point on the circle of radius FLANK_DISTANCE around
		var pos := Vector2.from_angle(randf() * TAU) * FLANK_DISTANCE * (1 + randf_range(-FLANK_DISTANCE_RANDOMESS, FLANK_DISTANCE_RANDOMESS))
		var globalPos := pos + center

		var score := INF
		for enemy : Vector2 in enemies:
			score = minf(score, globalPos.distance_squared_to(enemy))

		if score > bestScore:
			bestScore = score
			bestTarget = pos

	return bestTarget
