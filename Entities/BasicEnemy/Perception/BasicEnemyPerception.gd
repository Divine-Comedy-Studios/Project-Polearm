extends Node3D
class_name BasicEnemyPerception


#region Exported variables

@export_group("Detection settings")
@export var MAX_RANGE : float = 20
# Placeholder until the perception manager exists: if enabled, the target is always known, regardless of range
@export var ALWAYS_AWARE : bool = true

#endregion


#region Member variables

var target : Node3D = null
var detected : bool = false

var lastKnownPosition : Vector3 = Vector3.ZERO
var destination : Vector3 = Vector3.ZERO

var _hasDestination : bool = false

#endregion


#region Public functions

func tick() -> void:
	detected = false

	if target == null or not is_instance_valid(target):
		# @todo Assumes the node in the "Player" group is the moving player model (like EncounterTrigger does)
		target = get_tree().get_first_node_in_group("Player") as Node3D
 
	if target == null:
		return
 
	requestTargetCheck(target.global_position)
 
 
func requestTargetCheck(targetPosition : Vector3) -> void:
	if not ALWAYS_AWARE and global_position.distance_to(targetPosition) > MAX_RANGE:
		return
 
	# @todo Line of sight check using the RAY_* settings, and a field of view check.
	# Basic version: if the target is in range, it is detected.
 
	detected = true
	lastKnownPosition = targetPosition
	destination = targetPosition
	_hasDestination = true
 
 
func hasDestination() -> bool:
	return _hasDestination
 

func flatOffsetToDestination() -> Vector2:
	return Vector2(destination.x - global_position.x, destination.z - global_position.z)


func reset() -> void:
	target = null
	detected = false
	_hasDestination = false

#endregion
