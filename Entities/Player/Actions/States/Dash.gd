extends PlayerAction


#region Exported variables

@export_group("Movement settings")
@export var DASH_SPEED : float = 16.0
@export var ACCELERATION : float = 50.0

#endregion


#region Member variables

var _direction : Vector3 = Vector3.ZERO

#endregion


#region Override functions

func _implEnter() -> void:
	_direction = Vector3(inputs().direction.x, 0, inputs().direction.y)
	if _direction.is_zero_approx():
		_direction = player().forward()
	else:
		_direction = _direction.normalized()

	_setupBasicAnimation()


func _tick(delta : float) -> void:
	player().accelerateFlat3(_direction * DASH_SPEED, ACCELERATION * delta)

	if inputs().modifiers.has(Type.sprint):
		context().pushActionQueue(Type.sprint)
	elif player().onGround():
		context().pushActionForced(Type.dashStop)

#endregion
