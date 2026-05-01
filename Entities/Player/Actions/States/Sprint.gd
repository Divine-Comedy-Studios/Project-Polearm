extends PlayerAction


#region Exported variables

@export_group("Movement settings")
@export var SPRINT_SPEED : float = 12.0
@export var ACCELERATION : float = 30.0

#endregion


#region Member variables

var _direction : Vector3 = Vector3.ZERO

#endregion


#region Override functions

func _viable() -> bool:
	return player().onGround()


func _implEnter() -> void:
	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME
	animator().transitionToUnused(&"BasicTransition", 
		animator().setCoreTransition(&"BasicTransition", data.ANIMATION_FADE_TIME))


func _implExit() -> void:
	_direction = Vector3.ZERO


func _tick(delta : float) -> void:
	var dir := inputs().direction
	if dir.is_zero_approx():
		_direction = player().forward()
	else:
		_direction.x = dir.x
		_direction.z = dir.y

	player().accelerateFlat3(_direction * SPRINT_SPEED, ACCELERATION * delta)

#endregion
