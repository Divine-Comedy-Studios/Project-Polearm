extends Node3D
class_name EnemyPerception


#region Helper structures

class Data extends RefCounted:
	var role : EnemyManager.Role = EnemyManager.Role.idle

	var detected : bool = false
	var hasTarget : bool = false
	var target : Vector3 = Vector3.ZERO

#endregion


#region Exported variables

@export_group("Detection settings")
@export var MAX_RANGE : float = 20

#endregion


#region Member variables

# Perception state is shared between all enemies

var _target : Node3D = null
var _targetPos : Vector3 = Vector3.ZERO

var _lastKnownPosition : Vector3 = Vector3.ZERO
var _hasLastKnownPosition : bool = false

#endregion


#region Public functions

func tick() -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("Player") as Node3D


func request(pos : Vector3, role : EnemyManager.Role) -> Data:
	var data := Data.new()

	if _target != null:
		_targetPos = _target.global_position

		data.detected = pos.distance_to(_targetPos) <= MAX_RANGE

		if data.detected:
			_lastKnownPosition = _targetPos
			_hasLastKnownPosition = true

	data.hasTarget = _hasLastKnownPosition
	data.target = _lastKnownPosition

	data.role = role

	return data


func reset() -> void:
	_target = null
	_hasLastKnownPosition = false

#endregion
