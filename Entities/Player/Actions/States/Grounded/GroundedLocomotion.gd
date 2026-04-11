extends PlayerBasicGrounded


@export_group("Movement settings")
@export var ACCELERATION : float = 25.0
@export var RUN_SPEED_MAX : float = 5.0


@export_group("Animation settings")
@export var IDLE_DATA : PlayerActionData = null
@export var WALK_DATA : PlayerActionData = null
@export var RUN_DATA : PlayerActionData = null


func _implInit() -> void:
	assert(IDLE_DATA != null, "GroundedLocomotion._implInit(): Idle action data not assigned")
	assert(WALK_DATA != null, "GroundedLocomotion._implInit(): Walking action data not assigned")
	assert(RUN_DATA != null, "GroundedLocomotion._implInit(): Running action data not assigned")

	data = WALK_DATA


func _implEnter() -> void:
	var transitionHandle := animator().transitionHandle()
	
	var animationHandle := animator().animationHandle()
	var animationDriver := animator().animationDriver(animationHandle)
	animationDriver.animation = data.ANIMATION_FULL_NAME

	animator().transitionTo(transitionHandle, animationHandle)

func _implExit() -> void:
	pass


func _tick(delta : float) -> void:
	var targetSpeed := minf(inputs().inputMagnitude * RUN_SPEED_MAX, RUN_SPEED_MAX)

	player().accelerateFlat(inputs().direction * targetSpeed, ACCELERATION * delta)
