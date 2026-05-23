extends BasicAerialMovement
class_name PlayerBasicJump


#region Exported variables

@export_group("Dynamic jump settings")
@export var MAX_TIME_MILLISECONDS : float = 0.1

#endregion


#region Member variables

# Variable jump height

var _framesSinceStarted : float = 0.0

@export_group("Dynamic jump")
@export var jumpHeightFactor : float = 1.0


# Settings cache

var _baseJumpVel : float = 0.0
var _jumpAccel : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_baseJumpVel = physics().BASE_JUMP_VELOCITY
	_jumpAccel = physics().JUMP_ACCELERATION


func _implEnter() -> void:
	player().setMovementVertical(jumpHeightFactor * _baseJumpVel)

	_animationSetupBasic()

func _implExit() -> void:
	_framesSinceStarted = 0.0


func _tick(delta : float) -> void:
	if player().onCeiling():
		context().interrupt(Type.fall)
		return

	moveAerial(delta)

	# Additional jump velocity
	if inputs().modifiers.has(Type.jump) and _framesSinceStarted < MAX_TIME_MILLISECONDS:
		player().accelerateVertical(100.0, jumpHeightFactor * _jumpAccel * minf(delta, MAX_TIME_MILLISECONDS - _framesSinceStarted))

	_framesSinceStarted += delta


func _implNextAction(next : StringName) -> StringName:
	return next

#endregion
