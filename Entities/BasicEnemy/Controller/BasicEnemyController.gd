extends Node
class_name BasicEnemyController


#region Helper structures

class Data extends RefCounted:
	var magnitude : float
	var direction : Vector2
	var targetPosition : Vector3

	var actions : Array[StringName]
	var modifiers : Array[StringName]

	func reset() -> void:
		magnitude = 0.0
		direction = Vector2.ZERO
		targetPosition = Vector3.ZERO

		actions.clear()
		modifiers.clear()

#endregion


#region Exported variables

@export_group("Combat")
@export var AVAILABLE_ROLES : Array[EnemyManager.Role] = [ EnemyManager.Role.idle ]
@export_range(0.0, 180.0) var ATTACK_FACING_ANGLE_DEGREES : float = 25.0

#endregion


#region Scene members

@export_group("Scene members")
@export var entity : Node3D = null

#endregion


#region Member variables

var intents : Data = Data.new()

var currentRole : EnemyManager.Role = EnemyManager.Role.idle

var requestRoleChange : bool = false:
	set(value):
		requestRoleChange = value
	get:
		var tmp := requestRoleChange
		requestRoleChange = false
		return tmp

#endregion


#region Built-in functions

func _ready() -> void:
	assert(entity != null, "BasicEnemyController._ready(): Entity was not assigned!")
	assert(AVAILABLE_ROLES.has(EnemyManager.Role.idle), "BasicEnemyController._ready(): Available roles needs to contain idle!")

	reset()

#endregion


#region Public functions

func tick(delta, perceptionData : EnemyPerception.Data) -> void:
	currentRole = perceptionData.role

	intents.reset()
	intents.actions.append(BasicEnemyAction.Type.idle)

	if not perceptionData.hasTarget:
		return

	var offset := PPUtil.Math.toFlatVec2(perceptionData.target - entity.global_position)
	var distance := offset.length()
	var toTarget := offset / distance

	intents.direction = toTarget
	intents.targetPosition = _tickAndTarget(delta, distance, toTarget, perceptionData)


func reset() -> void:
	intents.reset()

	currentRole = EnemyManager.Role.idle

	_implReset()

#endregion


#region Private functions

func _canAttack(distance : float, attackRange : float, toTarget : Vector2, forward : Vector3) -> bool:
	if distance > attackRange:
		return false

	var flatForward := Vector2(forward.x, forward.z)
	if flatForward.is_zero_approx():
		return true

	return absf(flatForward.angle_to(toTarget)) <= deg_to_rad(ATTACK_FACING_ANGLE_DEGREES)

#endregion


#region Implementation functions

@warning_ignore("unused_parameter")
func _tickAndTarget(delta : float, distance : float, toTarget : Vector2, perceptionData : EnemyPerception.Data) -> Vector3:
	return Vector3.ZERO


func _implReset() -> void:
	pass

#endregion
