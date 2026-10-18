extends Node
class_name BasicEnemyController


#region Helper structures

class Data extends RefCounted:
	var magnitude : float
	var direction : Vector2

	var target : Node3D

	var actions : Array[StringName]

	func reset() -> void:
		magnitude = 0.0
		direction = Vector2.ZERO

		target = null

		actions.clear()

#endregion


#region Exported variables

@export_group("Combat")
@export var AVAILABLE_ROLES : Array[EnemyManager.Role] = [ EnemyManager.Role.idle ]
@export var ATTACK_RANGE : float = 2
@export_range(0.0, 180.0) var ATTACK_FACING_ANGLE_DEGREES : float = 25.0

#endregion


#region Scene members

@export_group("Scene members")
@export var entity : Node3D = null

#endregion


#region Member variables

var intents : Data = Data.new()

var currentRole : EnemyManager.Role = EnemyManager.Role.idle
var requestRoleChange : bool = false

#endregion


#region Built-in functions

func _ready() -> void:
	assert(entity != null, "BasicEnemyController._ready(): Entity was not assigned!")
	assert(AVAILABLE_ROLES.has(EnemyManager.Role.idle), "BasicEnemyController._ready(): Available roles needs to contain idle!")

	reset()

#endregion


#region Public functions

func tick(delta, perceptionData : EnemyPerception.Data) -> void:
	if requestRoleChange:
		requestRoleChange = (currentRole == perceptionData.role)

	currentRole = perceptionData.role

	intents.reset()
	intents.actions.append(BasicEnemyAction.Type.idle)

	if not perceptionData.hasTarget:
		return

	intents.target = perceptionData.target
	
	_tick(delta, perceptionData)


func reset() -> void:
	intents.reset()

	currentRole = EnemyManager.Role.idle

	_implReset()

#endregion


#region Private functions

func _canAttack(distance : float, toTarget : Vector2, forward : Vector3) -> bool:
	if distance > ATTACK_RANGE:
		return false

	var flatForward := Vector2(forward.x, forward.z)
	if flatForward.is_zero_approx():
		return true

	return absf(flatForward.angle_to(toTarget)) <= deg_to_rad(ATTACK_FACING_ANGLE_DEGREES)

#endregion


#region Implementation functions

@warning_ignore("unused_parameter")
func _tick(delta : float, perceptionData : EnemyPerception.Data) -> void:
	pass


func _implReset() -> void:
	pass

#endregion
