extends PlayerAction


#region Exported variables

@export_group("Movement settings")
@export var MAX_SPEED : float = 5.0
@export var ACCELERATION : float = 20.0
@export var FRICTION : float = 10.0

@export_group("Jump settings")
@export var BASE_JUMP_VELOCITY : float = 7.0
@export var JUMP_ACCELERATION : float = 30.0
@export var MAX_JUMP_VELOCITY : float = 15.0
@export var MAX_TIME_MILLISECONDS : float = 0.1
@export var MULTI_JUMP_HEIGHT_FACTOR : float = 0.9

#endregion


#region Member variables

var _framesSinceStarted : float = 0.0
var _jumpHeightFactor : float = 1.0

#endregion


#region Override functions

func _implEnter() -> void:
	for i : int in range(resources().jumpCount.value):
		_jumpHeightFactor *= MULTI_JUMP_HEIGHT_FACTOR

	player().detachGround()
	player().disableCollisionProcessing()
	player().setMovementVertical(_jumpHeightFactor * BASE_JUMP_VELOCITY)

	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME
	animator().transitionToUnused(&"BasicTransition", 
		animator().setCoreTransition(&"BasicTransition", data.ANIMATION_FADE_TIME))


func _implExit() -> void:
	_framesSinceStarted = 0.0
	_jumpHeightFactor = 1.0
	player().enableCollisionProcessing()


func _tick(delta : float) -> void:
	if player().onCeiling():
		_framesSinceStarted = MAX_TIME_MILLISECONDS
		return

	# Movement
	var targetSpeed := minf(inputs().inputMagnitude * MAX_SPEED, MAX_SPEED)

	if is_zero_approx(targetSpeed):
		player().accelerateFlat(Vector3.ZERO, FRICTION * delta)
	else:
		player().accelerateFlat(inputs().direction * targetSpeed, ACCELERATION * delta)

	# Additional jump velocity
	if inputs().modifiers.has(Type.jump):
		player().accelerateVertical(MAX_JUMP_VELOCITY, _jumpHeightFactor * JUMP_ACCELERATION * minf(delta, MAX_TIME_MILLISECONDS - _framesSinceStarted))

	_framesSinceStarted += delta


func _implNextAction(next : StringName) -> StringName:
	if _framesSinceStarted >= MAX_TIME_MILLISECONDS:
		return next

	return Type.none if context().hasHigherPriority(TYPE, next) else next

#endregion
