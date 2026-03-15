# The logic behind the structure derive loosely from the methods used in https://github.com/NoiRC256/SRMove/
# A forward probing function to apply smoothing during movement is directly inspired by the library

extends CharacterBody3D
class_name FloatingBody


#region Helper classes

class GroundData extends RefCounted:
	var point : Vector3 = Vector3.ZERO
	var normal : Vector3 = Vector3.ZERO

	var offset : float = 0

	var grounded : bool = false

	func clear() -> void:
		point = Vector3.ZERO
		normal = Vector3.ZERO
		offset = 0
		grounded = false
	
	func copy(other : GroundData) -> void:
		point = other.point
		normal = other.normal
		offset = other.offset
		grounded = other.grounded

#endregion


#region Enums

enum StepState {
	none,
	up,
	down,
}

#endregion


#region Constants

# Generall physics and collision settings

const MAX_GROUND_COLLISIONS : int = 4
const COLLISION_EPSILON : float = 0.001
const GROUND_DISTANCE_BUFFER = 1.01
const MIN_STEP_SPEED : float = 0.1 # Rigidbody collision resolution wants to move up on ledges
const VELOCITY_VERTICAL_OVERCORRECTION_FACTOR : float = 2.0


# Raycast settings

const STEP_RAY_SCALE_FACTOR : int = 4
const DOWNWARDS_RAY_LENGTH := Vector3(0.0, 10.0, 0.0)


# Hitbox configuration settings

const GROUND_CAST_DIST_TO_GROUND : float = 1
const STEP_RAY_VERTICAL_OFFSET : float = 0.03

#endregion


#region Exported variables

@export_group("Collider settings")
@export var CHARACTER_HEIGHT :float = 1.8
@export var BODY_COLLIDER_RADIUS = 0.5
@export var BODY_COLLIDER_FLOATING_HEIGHT : float = 0.3
@export var GROUND_CAST_RADIUS : float = 0.4

@export_group("Slope settings")
@export_range(-360, 360, 0.001, "radians_as_degrees") var SLOPE_MAX_ANGLE : float = 0.786

@export_group("Step settings")
@export var STEP_MAX_HEIGHT : float = 0.41
@export var STEP_MAX_DEPTH : float = 0.3
@export var STEP_SPEED_FACTOR : float = 0.4

#endregion


#region Scene members

@export_group("Scene Members")
@export var bodyCollider : CollisionShape3D
@export var groundCast : ShapeCast3D

#endregion


#region Member variables

# References

@onready var BUFFERED_MAX_GROUND_DISTANCE := (BODY_COLLIDER_FLOATING_HEIGHT + STEP_MAX_HEIGHT) * GROUND_DISTANCE_BUFFER
@onready var UNBUFFERED_MAX_GROUND_DISTANCE := BODY_COLLIDER_FLOATING_HEIGHT * GROUND_DISTANCE_BUFFER
@onready var BODY_COLLIDER_HEIGHT := CHARACTER_HEIGHT - BODY_COLLIDER_FLOATING_HEIGHT

@onready var SLOPE_MAX_ANGLE_COS := cos(SLOPE_MAX_ANGLE)
@onready var COLLISION_LAYERS := groundCast.collision_mask

@onready var _bodyColliderShape := bodyCollider.shape as CapsuleShape3D
@onready var _groundCastShape := groundCast.shape as SphereShape3D


# State

var _groundData : GroundData = GroundData.new()
var _footData : GroundData = GroundData.new()
var _groundedData : GroundData = null # Reference to the current ground data which is grounded

var _stepState : StepState = StepState.none
var _validStepDepth : bool = true

var _grounded : bool = true

var _velocityLength : float = 0


# Caching

@onready var _rayQuery : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, COLLISION_LAYERS)
@onready var _motionParameters : PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()

@onready var _motionBodyData : Dictionary[String, float] = { "height" : BODY_COLLIDER_HEIGHT, "radius" : BODY_COLLIDER_RADIUS }

@onready var _collisionProbeBody : RID = PhysicsServer3D.body_create()
@onready var _collisionProbeShape : RID = PhysicsServer3D.capsule_shape_create()

#endregion


#region Public functions

func init() -> void:
	_configureHitboxes()

func tick(delta : float) -> void:
	_processCollisions()

	_calculateVelocity(delta)
	move_and_slide()
	#DEBUG_drawCollisionPoints()

	_resetFrame()


# Movement functions


func snapToFloor() -> void:
	position.y -= _groundData.offset


# State functions

func onGround() -> bool:
	return _grounded

func onlyOnGround() -> bool:
	return onGround() and not is_on_ceiling() and not is_on_wall()

func onCeiling() -> bool:
	return is_on_ceiling()

func onlyOnCeiling() -> bool:
	return is_on_ceiling() and not onGround() and not is_on_wall()

func onWall() -> bool:
	return is_on_wall()

func onlyOnWall() -> bool:
	return is_on_wall() and not is_on_ceiling() and not onGround()


# Ground functions

func groundPoint() -> Vector3:
	return _groundedData.point

func groundNormal() -> Vector3:
	return _groundedData.normal

func forceGroundDataUpdate() -> void:
	if _stepState == StepState.down:
		_processFootCollisionData(_groundData)
	else:
		groundCast.force_shapecast_update()
		_processGroundCollisionData(_groundData)
	
	if _stepState != StepState.down:
		_groundedData = _groundData


#endregion


#region Private functions

# Initialization functions

func _configureHitboxes() -> void:
	groundCast.max_results = MAX_GROUND_COLLISIONS

	bodyCollider.position.y = BODY_COLLIDER_HEIGHT / 2 + BODY_COLLIDER_FLOATING_HEIGHT
	_bodyColliderShape.radius = BODY_COLLIDER_RADIUS
	_bodyColliderShape.height = BODY_COLLIDER_HEIGHT

	_groundCastShape.radius = GROUND_CAST_RADIUS

	PhysicsServer3D.shape_set_data(_collisionProbeShape, _motionBodyData)
	PhysicsServer3D.body_set_collision_mask(_collisionProbeBody, COLLISION_LAYERS)
	PhysicsServer3D.body_set_space(_collisionProbeBody, get_world_3d().space)
	PhysicsServer3D.body_add_shape(_collisionProbeBody, _collisionProbeShape)


# Physics functions

func _processCollisions() -> void:
	_processGroundCollisionData(_groundData)
	_processFootCollisionData(_footData)

	# First order of business, we check for groundedness

	if not _footData.grounded and not _groundData.grounded:
		_stepState = StepState.none
		_grounded = false

		return

	_grounded = true


	# Stepping collision checks

	_velocityLength = velocity.length_squared()
	if _velocityLength != 0:
		var direction := Vector3(velocity.x, 0, velocity.z)

		var checkStepDownResult := _checkStepDown(direction)
		if checkStepDownResult == 0:
			return
		elif checkStepDownResult == 1 and _checkStepUp(direction):
			return

	# If we are not stepping at all, we calculate a point in the direction the player is moving 
	# slightly behind the edge of the player hitbox. This allows us to perform a bit of smoothing

	if _footData.grounded and _validStepDepth:
		_probePointInDirection(_footData, global_position, velocity.normalized(), min(BODY_COLLIDER_RADIUS, sqrt(_velocityLength)), 4)


func _calculateVelocity(delta : float) -> void:
	const COLLISION_EPSILON_SQARED := COLLISION_EPSILON * COLLISION_EPSILON

	print(velocity)


	if not onGround(): # Flying ignores all below calculations
		return

	if _velocityLength != 0:
		if absf(_groundData.offset) < COLLISION_EPSILON:
			position.y -= _groundData.offset
			_groundData.offset = 0.0

		var line := Vector3(global_position.x, global_position.y, global_position.z) - _footData.point
		line.y *= VELOCITY_VERTICAL_OVERCORRECTION_FACTOR

		# If the horizontal OR vertical component of line is too small
		if absf(line.y) < COLLISION_EPSILON or (line.x * line.x + line.z * line.z) < COLLISION_EPSILON_SQARED:
			velocity = Utility.Math.rotateVectorOntoPlane(velocity, _groundData.normal)
		else:
			# The two cross products produce the final slope vector to rotate velocity by
			velocity = Utility.Math.rotateVectorOntoPlane(velocity, line.cross(_footData.normal).cross(line).normalized())
	else:
		if _stepState == StepState.none:
			return

		var absOffset := absf(_groundedData.offset)

		if absOffset > STEP_MAX_HEIGHT:
			_stepState = StepState.none
		elif absOffset > MIN_STEP_SPEED:
			velocity.y -= maxf(absOffset / delta, MIN_STEP_SPEED) * STEP_SPEED_FACTOR * signf(_groundedData.offset)
		else:
			position.y -= _groundedData.offset # Modify position directly for better snapping
			_stepState = StepState.none


func _resetFrame() -> void:
	_groundData.clear()
	_footData.clear()

	_validStepDepth = true


# Collision analysis functions

func _processGroundCollisionData(result : GroundData) -> void:
	if not groundCast.is_colliding():
		return

	result.point = _highestGroundPointGlobal()

	_initRayQuery(result.point + Vector3.UP, result.point - DOWNWARDS_RAY_LENGTH)
	var normalRayResult := get_world_3d().direct_space_state.intersect_ray(_rayQuery)

	if not normalRayResult:
		return

	if absf(result.point.y - (normalRayResult.position as Vector3).y) > COLLISION_EPSILON:
		# If we can't hit the same point as the sphereCast, we assume for safety that we are not grounded
		return

	result.offset = _vertOffsetToPlayerGlobal(result.point)
	result.normal = normalRayResult.normal as Vector3

	if result.offset <= _bufferedGroundMaxDistance() and result.normal.y > SLOPE_MAX_ANGLE_COS:
		# As the normal vector is normalized, its angle can be determined by simply checking for its height
		result.grounded = true

func _processFootCollisionData(result : GroundData) -> void:
	_initRayQuery(global_position + Vector3.UP, global_position - DOWNWARDS_RAY_LENGTH)
	var collision := get_world_3d().direct_space_state.intersect_ray(_rayQuery)

	if not collision:
		return

	result.point = collision.position
	result.offset = _vertOffsetToPlayerGlobal(result.point)
	result.normal = collision.normal

	if result.offset <= _bufferedGroundMaxDistance() and result.normal.y > SLOPE_MAX_ANGLE_COS:
		# As the normal vector is normalized, its angle can be determined by simply checking for its height
		result.grounded = true

# Gives the farthest point on the line from startingPos towards direction * distance, which is continuously grounded
func _probePointInDirection(result : GroundData, startingPos : Vector3, direction : Vector3, distance : float, iterations : int) -> void:
	var iterDistance := distance / iterations
	var iterShift := direction * iterDistance
	iterShift.y = 0

	var pos := startingPos + iterShift

	for i : int in range(iterations):
		var posOffset := Vector3(0, STEP_MAX_HEIGHT, 0) # We make our ray slightly lower than the max step height to prevent stepping to high)

		_initRayQuery(pos + posOffset, pos - DOWNWARDS_RAY_LENGTH)
		var collision := get_world_3d().direct_space_state.intersect_ray(_rayQuery)
		if not collision:
			break
		
		var dist := _vertOffsetToPlayerGlobal(collision.position)
		if dist > _bufferedGroundMaxDistance() or collision.normal.y <= SLOPE_MAX_ANGLE_COS:
			break

		result.point = collision.position
		result.offset = dist
		result.normal = collision.normal
		result.grounded = true
		
		pos += iterShift
		pos.y = collision.position.y


# Stepping functions

# This can return three values depending on the result
# 0: The probing was succesful
# 1: The probing failed before the wall has been checked
# 2: The probing failed during the wall check
func _checkStepDown(direction : Vector3) -> int:
	if (_stepState == StepState.down
		or not _footData.grounded
		or _footData.offset < STEP_RAY_VERTICAL_OFFSET):
		return 1

	if not _validateStepProbeQueryDirection(-direction):
		return 1

	_calculateStepWallProbeQuery(global_position, _groundData.point)
	if _probeStepWall(): # We don't need to check if the distance is too large for us to step down, as it was already done for _probeData.grounded
		_groundedData = _footData
		_stepState = StepState.down

		return 0

	return 2

func _checkStepUp(direction : Vector3) -> bool:
	if _stepState == StepState.up or not _groundData.grounded: # Here, this specifically needs to be grounded
		return false
	
	_motionParameters.from = Transform3D.IDENTITY
	_motionParameters.from.origin = Vector3(_groundData.point.x, _groundData.point.y - _groundData.offset + bodyCollider.position.y, _groundData.point.z)
	_motionParameters.motion = direction.normalized() * STEP_MAX_DEPTH

	_validStepDepth = not PhysicsServer3D.body_test_motion(_collisionProbeBody, _motionParameters)

	if (not _validStepDepth
		or _groundData.offset > -STEP_RAY_VERTICAL_OFFSET
		or _groundData.offset < -STEP_MAX_HEIGHT):
		return false

	if not _validateStepProbeQueryDirection(direction):
		return false
	if not _probeStepWall():
		return false

	_groundedData = _groundData
	_stepState = StepState.up

	return true


# Step wall validation functions

# Checks if the wall of a step is actually a wall and not a slope
func _probeStepWall() -> bool:
	_rayQuery.to += _rayQuery.from
	var collision := get_world_3d().direct_space_state.intersect_ray(_rayQuery)
	
	if collision and (collision.normal as Vector3).y <= SLOPE_MAX_ANGLE_COS:
		return true
	
	return false

# CAUTION: returns the non-globalized target position for usage in _validateStepProbeQueryDirection
func _calculateStepWallProbeQuery(sourcePointGlobal : Vector3, targetPointGlobal : Vector3) -> void:
	var sourcePos := Vector3(sourcePointGlobal.x, targetPointGlobal.y - STEP_RAY_VERTICAL_OFFSET, sourcePointGlobal.z)
	var targetPos := Vector3(targetPointGlobal.x - sourcePointGlobal.x, 0, targetPointGlobal.z - sourcePointGlobal.z) * STEP_RAY_SCALE_FACTOR

	_initRayQuery(sourcePos, targetPos)

# We also check for a direction variable to prevent the body is moving in a direction incompatible with the step direction
func _validateStepProbeQueryDirection(direction : Vector3) -> bool:
	if _rayQuery.to.dot(direction) < 0:
		return false
	return true


# Utility functions

# Also saves the index of the current point
func _highestGroundPointGlobal() -> Vector3:
	assert(groundCast.is_colliding(), "PlayerPhysics._highestGlobalGroundPoint(): The player ground detection cast is not colliding. Always check collisions first!")

	var result := groundCast.get_collision_point(0)

	for i : int in range(1, groundCast.get_collision_count()):
		var curr := groundCast.get_collision_point(i)

		if curr.y > result.y:
			result = curr
	
	return result

# The maximum ground distance introduces some leniency, which changes whether the player is on the ground or not
func _bufferedGroundMaxDistance() -> float:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
	if _grounded:
		return BUFFERED_MAX_GROUND_DISTANCE
	return UNBUFFERED_MAX_GROUND_DISTANCE

# Returns a negative value if the point is above the player, and a positive one if the point is below the player
func _vertOffsetToPlayerGlobal(globalPos : Vector3) -> float:
	return global_position.y - globalPos.y

# Assign our cached ray cast query
func _initRayQuery(from : Vector3, to : Vector3) -> void:
	_rayQuery.from = from
	_rayQuery.to = to


# Debug functionality, uncomment in tick() for debugging
func DEBUG_drawCollisionPoints() -> void:
	DebugDraw3D.draw_arrow(global_position, global_position + velocity, Color.YELLOW, 0.05)

	if groundCast.is_colliding():
		var points : PackedVector3Array
		for i in range(groundCast.get_collision_count()):
			var pt := groundCast.get_collision_point(i)

			points.push_back(pt)
			DebugDraw3D.draw_arrow(pt, pt + groundCast.get_collision_normal(i), Color.PINK, 0.05)

		DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1, Color.CRIMSON)

	if _groundData.point != Vector3.ZERO:
		var points : PackedVector3Array
		points.push_back(_groundData.point)
		DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1, Color.BLUE)
		DebugDraw3D.draw_arrow(_groundData.point, _groundData.point + _groundData.normal, Color.LIGHT_BLUE, 0.05)
	
	if _footData.point != Vector3.ZERO:
		var points : PackedVector3Array
		points.push_back(_footData.point)
		DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1, Color.GREEN)
		DebugDraw3D.draw_arrow(_footData.point, _footData.point + _footData.normal, Color.LIGHT_GREEN, 0.05)


#endregion
