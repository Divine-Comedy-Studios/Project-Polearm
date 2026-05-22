extends PlayerAction


#region Exported variables

@export_group("Movement settings")
@export var DASH_SPEED : float = 17.0
@export var ACCELERATION : float = 50.0

#endregion


#region Member variables

var _direction : Vector3 = Vector3.ZERO

#endregion


#region Override functions

func _implEnter() -> void:
	resources().jumpCount.value += 1

	_direction = Vector3(inputs().direction.x, 0, inputs().direction.y)
	if _direction.is_zero_approx():
		_direction = player().forward()
	
	_animationSetupBasic()


func _tick(delta : float) -> void:
	player().accelerateFlat3(_direction * DASH_SPEED, ACCELERATION * delta)

#endregion
