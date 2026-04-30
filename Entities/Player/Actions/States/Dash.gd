extends PlayerAction


#region Exported variables

@export_group("Movement settings")
@export var DASH_SPEED : float = 16.0
@export var ACCELERATION : float = 50.0

#endregion


#region Scene members

@export_group("Scene members")
@export var _timer : Timer = null

#endregion


#region Member variables

var _direction : Vector3 = Vector3.ZERO

#endregion


#region Override functions

func _viable() -> bool:
	return _timer.is_stopped()


func _implInit() -> void:
	assert(_timer != null, "Dash._implInit(): Assign dash timer!")


func _implEnter() -> void:
	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME
	animator().transitionToUnused(&"BasicTransition", 
		animator().setCoreTransition(&"BasicTransition", data.ANIMATION_FADE_TIME))
	
	_direction = Vector3(inputs().direction.x, 0, inputs().direction.y)
	if _direction.is_zero_approx():
		_direction = player().forward()
	else:
		_direction = _direction.normalized()


func _implExit() -> void:
	_timer.start()


func _tick(delta : float) -> void:
	player().accelerateFlat3(_direction * DASH_SPEED, ACCELERATION * delta)

	if inputs().actions.has(Type.sprint):
		context().pushActionQueue(Type.sprint)

#endregion
