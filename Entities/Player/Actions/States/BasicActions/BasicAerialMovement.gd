extends PlayerAction
class_name BasicAerialMovement


#region Member variables

# Movement settings

var _maxSpeed : float = 0.0
var _maxSpeedSq : float = 0.0
var _accel : float = 0.0
var _friction : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_maxSpeed = physics().MAX_AERIAL_SPEED
	_maxSpeedSq = _maxSpeed * _maxSpeed
	_accel = physics().AERIAL_ACCELERATION
	_friction = physics().AERIAL_FRICTION

#endregion


#region Public functions

func moveAerial(delta : float) -> void:
	var targetSpeed := minf(inputs().inputMagnitude * _maxSpeed, _maxSpeed)

	if not is_zero_approx(targetSpeed):
		# Get the old velocity
		var velocity : Vector3 = player().movement()
		var currentVelocity : Vector2 = Vector2(velocity.x, velocity.z)
		var currentVelocityLen := currentVelocity.length_squared()
		
		# Conditionlessly accelerate the current velocity towards the requested direction
		currentVelocity += inputs().direction * inputs().inputMagnitude * _accel * delta
		var newVelocityLen := currentVelocity.length_squared()

		# If the velocity is larger than the max speed and hasn't gotten smaller, we normalize it and multiply it by its old length
		if newVelocityLen > currentVelocityLen:
			if currentVelocityLen > _maxSpeedSq: 
				currentVelocity = (currentVelocity / sqrt(newVelocityLen)) * sqrt(currentVelocityLen)
			elif newVelocityLen > _maxSpeedSq:
				currentVelocity = (currentVelocity / sqrt(newVelocityLen)) * _maxSpeed

		# Set the velocity
		player().setMovementFlat(currentVelocity)

	player().accelerateFlat(Vector3.ZERO, _friction * delta)

#endregion
