extends BasicAerialMovement
class_name PlayerBasicJump


#region Exported variables

@export_group("Dynamic jump settings")
@export var MAX_TIME_MILLISECONDS : float = 0.1
@export var RISE_GRAVITY : float = 60.0

#endregion


#region Member variables

var _framesSinceStarted : float = 0.0

@export var jumpHeightFactor : float = 1.0 # Export for testability, don't configure

var _baseJumpVel : float = 0.0
var _jumpAccel : float = 0.0

var _gravity : float = 0.0 ### @todo Not a todo, but marker for when we want to change the jump gravity to be universal, remove otherwise

#endregion


#region Override functions

func _implInit() -> void:
	_baseJumpVel = physics().BASE_JUMP_VELOCITY
	_jumpAccel = physics().JUMP_ACCELERATION
	_gravity = physics().REDUCED_JUMP_GRAVITY

	super._implInit()


func _implEnter() -> void:
	var velocity : Vector3 = player().movement()

	if inputs().direction != Vector2.ZERO: # If the player is going in another direction, just snap him into the direction
		player().setMovementFlat(
			Vector2(velocity.x, velocity.z).length() * inputs().direction * physics().DIRECTIONAL_SNAP_FACTOR)

	player().setMovementVertical(jumpHeightFactor * _baseJumpVel)

	_animationSetupBasic()

func _implExit() -> void:
	_framesSinceStarted = 0.0


func _tick(delta : float) -> void:
	if player().onCeiling() or player().movement().y == 0.0:
		context().interrupt(Type.fall)
		return

	moveAerial(delta)

	# Additional jump velocity
	if inputs().modifiers.has(Type.jump) and _framesSinceStarted < MAX_TIME_MILLISECONDS:
		player().accelerateVertical(100.0, # Arbitrary maximum variable
			jumpHeightFactor * _jumpAccel * minf(delta, MAX_TIME_MILLISECONDS - _framesSinceStarted)
			+ RISE_GRAVITY * delta
		)

	player().accelerateVertical(0.0, RISE_GRAVITY * delta)

	_framesSinceStarted += delta


func _implNextAction(next : StringName) -> StringName:
	return next

#endregion
