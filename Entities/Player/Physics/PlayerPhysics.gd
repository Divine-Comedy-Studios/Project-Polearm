extends Node3D
# Referred to internally as Player Physics Processor
class_name PlayerPhysics


#region Helper classes

class LedgeData:
	var collided : bool = false

	var point : Vector3 = Vector3.ZERO
	var normal : Vector3 = Vector3.ZERO

	func reset() -> void:
		collided = false
		point = Vector3.ZERO
		normal = Vector3.ZERO

#endregion


#region Exported variables

@export_group("Ledge settings")
@export var LEDGE_MAX_DISTANCE : float = 0.1

@export var LEDGE_MIN_DEPTH : float = 0.05

@export var LEDGE_MAX_HEIGHT : float = 2.3
@export var LEDGE_MIN_HEIGHT : float = 2.1
@export var LEDGE_MIN_CEILING_HEIGHT : float = 0.1

@export_range(-360, 360, 0.001, "radians_as_degrees") var LEDGE_SWEEP_SIDE_ANGLE : float = 0.1
@export var LEDGE_SWEEP_COUNT : int = 24

#endregion


#region Scene members

@export_group("Scene members")
@export var _player : Player = null

#endregion


#region Member variables

# References

@onready var LEDGE_SWEEP_TOTAL_ANGLE := LEDGE_SWEEP_SIDE_ANGLE * 2
@onready var LEDGE_SWEEP_SINGLE_ANGLE := LEDGE_SWEEP_TOTAL_ANGLE / LEDGE_SWEEP_COUNT
@onready var LEDGE_MAX_CEILING_OFFSET := LEDGE_MAX_HEIGHT + LEDGE_MIN_CEILING_HEIGHT
@onready var LEDGE_SWEEP_DISTANCE : float = 1#_player.BODY_COLLIDER_RADIUS + LEDGE_MAX_DISTANCE
@onready var LEDGE_MINIMUM_DIST : float = 1#_player.BODY_COLLIDER_RADIUS + LEDGE_MIN_DEPTH

# State

var ledgeData : LedgeData = LedgeData.new()


# Cache

@onready var _rayQuery : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, 0)

#endregion


#region Built-in funcitons

func _ready() -> void:
	assert(_player != null, "PlayerPhysics._ready(): Player not assigned!")

	_rayQuery.collision_mask = _player.collision_mask

#endregion


#region Public funcitons

func sweepLedge() -> void:
	# Caching
	var TOP_MAX_HEIGHT := global_position.y + LEDGE_MAX_CEILING_OFFSET
	var TOP_MIN_HEIGHT := global_position.y + LEDGE_MIN_HEIGHT

	# Reset collision data first
	ledgeData.reset()

	# Calculate the position to start the ledge sweep at
	var forward := -transform.basis.z
	var pos := Vector3(forward.x, 0, forward.z).rotated(Vector3.UP, -LEDGE_SWEEP_SIDE_ANGLE).normalized() * LEDGE_SWEEP_DISTANCE

	var absCollidedAngle : float = INF
	var currentAngle : float = -LEDGE_SWEEP_SIDE_ANGLE


	for i : int in range(LEDGE_SWEEP_COUNT):
		_setRayQuery(
			Vector3(pos.x, TOP_MAX_HEIGHT, pos.z),
			Vector3(pos.x, TOP_MIN_HEIGHT, pos.z))
		
		if _processLedgeCollision(TOP_MAX_HEIGHT):
			absCollidedAngle = abs(currentAngle)


		# Rotate the position vector to the next sweep point

		currentAngle += LEDGE_SWEEP_SINGLE_ANGLE
		if abs(currentAngle) > absCollidedAngle:
			# If the angle of the place we are already collided at is smaller, then
			# all other angles going forward will only grow bigger, hence we stop
			return
		
		pos = pos.rotated(Vector3.UP, LEDGE_SWEEP_SINGLE_ANGLE) #.normalized() * LEDGE_SWEEP_DISTANCE

#endregion


#region Private functions

# Collision functions

func _processLedgeCollision(maxHeight : float) -> bool:		
	var collision := get_world_3d().direct_space_state.intersect_ray(_rayQuery)

	if !collision:
		return false
	
	ledgeData.point = collision.position as Vector3
	ledgeData.normal = collision.normal as Vector3

	if maxHeight - ledgeData.point.y < LEDGE_MIN_CEILING_HEIGHT:
		return false
	if !_player.slopeWalkable(ledgeData.normal):
		return false
	
	var toCollisionPoint := ledgeData.point - global_position
	toCollisionPoint.y = 0

	if toCollisionPoint.length() - LEDGE_MINIMUM_DIST < 0:
		return false

	ledgeData.collided = true
	return true


# Utility functions

# Assign our cached ray cast query
func _setRayQuery(from : Vector3, to : Vector3) -> void:
	_rayQuery.from = from
	_rayQuery.to = to

#endregion
