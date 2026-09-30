extends PlayerAction
class_name BasicAerialMovement


#region Member variables

# Movement settings

var _maxSpeed : float = 0.0
var _accel : float = 0.0
var _friction : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_maxSpeed = physics().MAX_AERIAL_SPEED
	_accel = physics().AERIAL_ACCELERATION
	_friction = physics().AERIAL_FRICTION

#endregion


#region Public functions

func moveAerial(delta : float) -> void:
	var targetSpeed := minf(inputs().inputMagnitude * _maxSpeed, _maxSpeed)

	if not is_zero_approx(targetSpeed):
		# Get the old velocity
		var velocity : Vector3 = player().movement()
		var currentVelocity := PPUtil.Math.toFlatVec2(velocity)
		var currentVelocityLen := currentVelocity.length()
		
		# Conditionlessly accelerate the current velocity towards the requested direction
		var newVelocity := currentVelocity.move_toward(inputs().direction * targetSpeed, delta * _accel)
		var newVelocityLen := newVelocity.length()

		# Preservation of momentum
		# If the player is breaking to fast, we simply just apply
		# the friction  Else we deaccelerate them as requested
		if (newVelocityLen >= currentVelocityLen or
			(newVelocityLen < currentVelocityLen and currentVelocityLen - newVelocityLen < _friction * delta)
		):
			player().setMovementFlat(newVelocity)

			return

	player().accelerateFlat(Vector2.ZERO, _friction * delta)

#endregion
