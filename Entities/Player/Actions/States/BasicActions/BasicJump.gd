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

var _gravity : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_baseJumpVel = physics().BASE_JUMP_VELOCITY
	_jumpAccel = physics().JUMP_ACCELERATION
	_gravity = physics().REDUCED_JUMP_GRAVITY

	super._implInit()


func _implEnter() -> void:
	var horizontalVel := PPUtil.Math.toFlatVec2(player().movement())

	if not inputs().direction.is_zero_approx() and not horizontalVel.is_zero_approx(): # If the player is going in another direction, just snap him into the direction
		var velLen := horizontalVel.length()
		var directionVelocityDot := inputs().direction.dot(horizontalVel / velLen)

		player().setMovementFlat(velLen * inputs().direction * (physics().DIRECTIONAL_SNAP_FACTOR * (1.0 - directionVelocityDot) + directionVelocityDot))

	player().setMovementVertical(jumpHeightFactor * _baseJumpVel)

	_animationSetupBasic()

func _implExit() -> void:
	_framesSinceStarted = 0.0


func _implTick(delta : float) -> void:
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
	if ((player().onCeiling() or player().movement().y < 0.01) and
		(next == Type.none or context().hasHigherPriority(Type.fall, next))):
		return Type.fall

	return next

#endregion
