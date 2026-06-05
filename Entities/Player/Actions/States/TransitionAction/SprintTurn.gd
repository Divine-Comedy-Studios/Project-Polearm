extends PlayerBasicStopAction


#region Exported variables

@export_group("Animation settings")
@export var TURN_LEFT_DATA : PlayerActionData = null
@export var TURN_RIGHT_DATA : PlayerActionData = null

#endregion


#region Member variables

var _duration : float = 0.0

var _targetAngle : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_duration = animator().animation(TURN_LEFT_DATA.ANIMATION_FULL_NAME).length


func _implEnter() -> void:
	var forward : Vector3 = player().forward()
	_targetAngle = inputs().direction.angle_to(Vector2(forward.x, forward.z).normalized()) # The direction remains valid due to the only way to reach this state being interrupts

	if _targetAngle > 0:
		data = TURN_LEFT_DATA
	else:
		data = TURN_RIGHT_DATA

	_animationSetupBasic()


func _tick(delta : float) -> void:
	super._tick(delta)

	if inputs().modifiers.has(Type.sprint):
		if finished():
			context().pushActionQueue(Type.sprint)
		else:
			context().pushActionQueue(Type.sprintTurn)
	else:
		context().pushActionQueue(Type.sprintStop)


func _processDirection(delta : float) -> void:
	var rotationTrackingSpeed := _targetAngle / _duration * delta
	if rotationTrackingSpeed != 0.0:
		_context.entity.rotate_y(rotationTrackingSpeed)

#endregion
