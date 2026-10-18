extends BasicEnemyController
class_name ArcherController


#region Exported variables

@export_group("Randomness")
@export var COOLDOWN_TIME : Vector2 = Vector2(0.5, 4.0)
@export var AIM_TIME : Vector2 = Vector2(0.4, 1.5)
@export_range(0.0, 1.0) var HOLD_FIRE_PROBABILITY : float = 0.2

#endregion


#region Member variables

var _aimTimer : float = -1.0
var _cooldownTimer : float = -1.0

#endregion


#region Implementation functions

func _tick(delta : float, perceptionData : EnemyPerception.Data) -> void:
	var offset := PPUtil.Math.toFlatVec2(perceptionData.targetPos - entity.global_position)
	var distance := offset.length()
	intents.direction = offset / distance

	if currentRole == EnemyManager.Role.ranged:
		if _cooldownTimer == INF:
			return

		if _cooldownTimer > 0.0:
			_cooldownTimer -= delta
			requestRoleChange = true

			return

		if (not perceptionData.detected and 
			not _canAttack(distance, intents.direction, -(entity as Node3D).global_basis.z)
		):
			return

		if _aimTimer < 0.0:
			_aimTimer = randf_range(AIM_TIME.x, AIM_TIME.y)

		intents.actions.append(ArcherAction.Type.aim)

		_aimTimer -= delta
		if _aimTimer > 0.0:
			return

		if randf() < HOLD_FIRE_PROBABILITY:
			_aimTimer = -1.0

			return

		intents.actions.append(ArcherAction.Type.shoot)


func _implReset() -> void:
	_aimTimer = -1.0

#endregion


#region Public functions

func beforeShot() -> void:
	requestRoleChange = true
	_cooldownTimer = INF

func afterShot() -> void:
	_cooldownTimer = randf_range(COOLDOWN_TIME.x, COOLDOWN_TIME.y)

#endregion
