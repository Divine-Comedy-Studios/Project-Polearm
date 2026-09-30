extends PlayerAction


#region Exported variables

@export var LEDGE_FORGET_DISTANCE_SQUARED := 0.09

#endregion


#region Member variables

var _currentLedgeData : PlayerPhysics.LedgeData = null
var _lastPosition : Vector3 = Vector3.INF

#endregion


#region Built-in functions

func _physics_process(_delta: float) -> void:
	if _lastPosition == Vector3.INF:
		return

	if _checkLastPosition():
		_lastPosition = Vector3.INF

#endregion


#region Override functions

func _viable() -> bool:
	return _lastPosition == Vector3.INF or _checkLastPosition()


func _implEnter() -> void:
	_currentLedgeData = physics().ledgeData

	resources().jumpCount.value = 0
	player().setMovement(Vector3.ZERO)

	_animationSetupBasic()

func _implExit() -> void:
	_lastPosition = player().global_position
	_currentLedgeData = null


func _implTick(_delta : float) -> void:
	if _checkDirection():
		context().pushActionQueue(TYPE)

#endregion


#region Private functions

func _checkDirection() -> bool:
	var dir := inputs().direction
	if dir == Vector2.ZERO:
		return true

	if PPUtil.Math.flatToVec3(dir).dot(PPUtil.Math.toFlatVec3(_currentLedgeData.wallNormal)) < -0.2:
		return true
	
	return false

func _checkLastPosition() -> bool:
	return (player().global_position - _lastPosition).length_squared() > LEDGE_FORGET_DISTANCE_SQUARED

#endregion
