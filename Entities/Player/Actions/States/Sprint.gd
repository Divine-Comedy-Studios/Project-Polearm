extends PlayerAction


#region Exported variables

@export_group("Movement settings")
@export var SPRINT_SPEED : float = 12.0

#endregion


#region Member variables

var _accel : float = 0.0

var _direction : Vector3 = Vector3.ZERO

#endregion


#region Override functions

func _viable() -> bool:
	return player().onGround()


func _implInit() -> void:
	_accel = physics().GROUNDED_ACCELERATION


func _implEnter() -> void:
	_setupBasicAnimation()


func _implExit() -> void:
	_direction = Vector3.ZERO


func _tick(delta : float) -> void:
	var dir := inputs().direction
	if dir.is_zero_approx():
		_direction = player().forward()
	else:
		_direction.x = dir.x
		_direction.z = dir.y

	player().accelerateFlat3(_direction * SPRINT_SPEED, _accel * delta)

	if inputs().modifiers.has(Type.sprint):
		context().pushActionQueue(Type.sprint)
	else:
		context().pushActionForced(Type.sprintStop)

#endregion
