extends Node3D
# Referred to internally as Player Physics Processor
class_name PlayerPhysics


#region Helper classes

class LedgeData:
	var collided : bool = false

	var point : Vector3 = Vector3.ZERO
	var normal : Vector3 = Vector3.ZERO
	var wallNormal : Vector3 = Vector3.ZERO

	func reset() -> void:
		collided = false
		point = Vector3.ZERO
		normal = Vector3.ZERO
		wallNormal = Vector3.ZERO

#endregion


#region Exported variables

@export_group("Grounded movement settings")
@export var WALK_SPEED : float = 2.0
@export var RUN_SPEED : float = 5.5
@export var SPRINT_SPEED : float = 12.0
@export var GROUNDED_ACCELERATION : float = 30.0
@export var GROUNDED_FRICTION : float = 30.0
@export var REDUCED_GROUNDED_FRICTION : float = 5.0

@export_group("Dash settings")
@export var DASH_SPEED : float = 16.0
@export var DASH_ACCELERATION : float = 50.0

@export_group("Aerial movement settings")
@export var MAX_AERIAL_SPEED : float = 6.0
@export var AERIAL_ACCELERATION : float = 20.0
@export var AERIAL_FRICTION : float = 10.0
@export var REDUCED_AERIAL_FRICTION : float = 5.0
@export var DIRECTIONAL_SNAP_FACTOR : float = 1.0

@export_group("Jump settings")
@export var BASE_JUMP_VELOCITY : float = 7.0
@export var JUMP_ACCELERATION : float = 30.0
@export var REDUCED_JUMP_GRAVITY : float = 10.0

@export_group("Ledge settings")
@export var LEDGE_MAX_DISTANCE : float = 0.2

@export var LEDGE_MAX_HEIGHT : float = 2.0
@export var LEDGE_MIN_HEIGHT : float = 1.8
@export var LEDGE_MIN_CEILING_HEIGHT : float = 0.2

@export_range(-360, 360, 0.001, "radians_as_degrees") var LEDGE_SWEEP_SIDE_ANGLE : float = 0.1
@export var LEDGE_SWEEP_COUNT : int = 24

#endregion


#region Scene members

@export_group("Scene members")
@export var _context : PlayerActionManager = null

var _player : Player = null

#endregion


#region Member variables

# References

@onready var LEDGE_SWEEP_TOTAL_ANGLE := LEDGE_SWEEP_SIDE_ANGLE * 2.0
@onready var LEDGE_SWEEP_SINGLE_ANGLE := LEDGE_SWEEP_TOTAL_ANGLE / LEDGE_SWEEP_COUNT
@onready var LEDGE_MAX_CEILING_OFFSET := LEDGE_MAX_HEIGHT + LEDGE_MIN_CEILING_HEIGHT

var LEDGE_SWEEP_DISTANCE : float = 0.0

# State

var ledgeData : LedgeData = LedgeData.new()


# Cache

@onready var _rayQuery : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, 0)

#endregion


#region Built-in funcitons

func _ready() -> void:
	assert(_context != null, "PlayerPhysics._ready(): Player action manager not assigned!")

	await _context.ready
	await _context.entity.ready

	_player = _context.entity as Player

	LEDGE_SWEEP_DISTANCE = _player.BODY_COLLIDER_RADIUS + LEDGE_MAX_DISTANCE

	_rayQuery.collision_mask = _player.collision_mask

#endregion


#region Public funcitons

func sweepLedge() -> void:
	var globalPos := _player.global_position

	# Reset collision data first
	ledgeData.reset()

	# Calculate the position to start the ledge sweep at
	var forward : Vector3 = _player.forward()
	var pos := Vector3(forward.x, 0, forward.z).rotated(Vector3.UP, -LEDGE_SWEEP_SIDE_ANGLE).normalized() * LEDGE_SWEEP_DISTANCE

	var absCollidedAngle : float = INF
	var currentAngle : float = -LEDGE_SWEEP_SIDE_ANGLE

	for i : int in range(LEDGE_SWEEP_COUNT):
		if _processLedgeCollision(pos, globalPos):
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

func _processLedgeCollision(pos : Vector3, globalPos : Vector3) -> bool:		
	var globalPosX := pos.x + globalPos.x
	var globalPosZ := pos.z + globalPos.z
	var maxHeight := globalPos.y + LEDGE_MAX_CEILING_OFFSET

	# Check vertical collision
	_setRayQuery(
		Vector3(globalPosX, maxHeight, globalPosZ),
		Vector3(globalPosX, globalPos.y + LEDGE_MIN_HEIGHT, globalPosZ))

	var collision := get_world_3d().direct_space_state.intersect_ray(_rayQuery)
	if !collision:
		return false
	
	ledgeData.point = collision.position as Vector3
	ledgeData.normal = collision.normal as Vector3

	if maxHeight - ledgeData.point.y < LEDGE_MIN_CEILING_HEIGHT:
		return false
	if !_player.slopeWalkable(ledgeData.normal):
		return false

	
	# Check lower wall normal

	var lowerWallOffset := ledgeData.point.y - LEDGE_MIN_CEILING_HEIGHT

	_setRayQuery(
		Vector3(globalPos.x, lowerWallOffset, globalPos.z),
		Vector3(globalPosX, lowerWallOffset, globalPosZ))

	collision = get_world_3d().direct_space_state.intersect_ray(_rayQuery)
	if !collision:
		return false

	ledgeData.wallNormal = collision.normal as Vector3
	if not is_zero_approx(ledgeData.wallNormal.y): # Only ledge grab on vertical surfaces
		return false

	ledgeData.collided = true
	return true


# Utility functions

# Assign our cached ray cast query
func _setRayQuery(from : Vector3, to : Vector3) -> void:
	_rayQuery.from = from
	_rayQuery.to = to

#endregion
