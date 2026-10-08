extends NinjaAction


#region Exported variables

@export_group("Movement settings")
@export var DASH_SPEED : float = 14.0
@export var DASH_ACCELERATION : float = 120.0

#endregion


#region Member variables

var _direction : Vector3 = Vector3.ZERO

#endregion


#region Override functions

func _viable() -> bool:
	return entity().onGround()


func _implEnter() -> void:
	if intents().direction.is_zero_approx():
		_direction = entity().forward()
	else:
		_direction = PPUtil.Math.flatToVec3(intents().direction).normalized()

	controller().beforeDash()

	_animationSetupBasic()

func _implExit() -> void:
	controller().afterDash()


func _implTick(delta : float) -> void:
	entity().accelerateFlat3(_direction * DASH_SPEED, DASH_ACCELERATION * delta)

#endregion
