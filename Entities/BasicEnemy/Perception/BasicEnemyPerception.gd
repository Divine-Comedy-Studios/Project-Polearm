extends Node3D
class_name BasicEnemyPerception


#region Exported variables

@export_group("Detection settings")
@export var MAX_RANGE : float = 20
@export var RAY_COUNT : Vector2 = Vector2(5, 5)
@export var RAY_DISTANCE : float = 0.2

#endregion


#region Member variables

var target : Node3D

var lastKnownPosition : Vector3
var destination : Vector3

#endregion


#region Member functions

func requestTargetCheck(targetPosition : Vector3) -> void:
	pass

#endregion
