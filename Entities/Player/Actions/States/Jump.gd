extends BasicAerialMovement


#region Exported variables

@export_group("Jump settings")

@export var JUMP_HEIGHT : float = 3.0
@export var TIME_TO_PEAK : float = 0.4
@export var JUMP_CUT_MULTIPLIER : float = 3.0
@export var MULTI_JUMP_HEIGHT_FACTOR : float = 0.9

@export_group("Animation data")
@export var GROUND_JUMP_DATA : PlayerActionData = null
@export var AIR_JUMP_DATA : PlayerActionData = null

#endregion


#region Member variables

var _jumpHeightFactor : float = 1.0
var _jumpVelocity : float = 0.0
var _riseGravity : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	assert(GROUND_JUMP_DATA != null, "Player.Jump._implInit(): Ground jump animation data not set!")
	assert(AIR_JUMP_DATA != null, "Player.Jump._implInit(): Air jump animation data not set!")

	_riseGravity = (2.0 * JUMP_HEIGHT) / pow(TIME_TO_PEAK, 2.0)
	_jumpVelocity = sqrt(2.0 * _riseGravity * JUMP_HEIGHT)

	super._implInit()


func _implEnter() -> void:
	_entrySpeed = minf(Vector3(player().velocity.x, 0.0, player().velocity.z).length(), MAX_ENTRY_SPEED)
	for i : int in range(resources().jumpCount.value):
		_jumpHeightFactor *= MULTI_JUMP_HEIGHT_FACTOR

	if not player().onGround():
		data = AIR_JUMP_DATA
	else:
		data = GROUND_JUMP_DATA

	player().detachGround()
	player().disableCollisionProcessing()
	player().setMovementVertical(_jumpHeightFactor * _jumpVelocity)

	_setupBasicAnimation()

func _implExit() -> void:
	_jumpHeightFactor = 1.0
	player().enableCollisionProcessing()


func _tick(delta : float) -> void:
	if player().onCeiling():
		context().interrupt(Type.fall)
		return

	moveAerial(delta)

	# Additional jump velocity
	if not inputs().modifiers.has(Type.jump):
		player().accelerateVertical(0.0, _riseGravity * JUMP_CUT_MULTIPLIER * delta)
	else:
		player().accelerateVertical(0.0, _riseGravity * delta)


func _implNextAction(next : StringName) -> StringName:
	return next

#endregion
