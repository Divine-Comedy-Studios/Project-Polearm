@tool

extends Projectile
class_name Arrow


#region Member variables

var _gravity : float = 0.0

#endregion


#region Override functions

func _spawn(physics : ProjectilePhysics) -> void:
	_gravity = physics.GRAVITY

	var direction := PPUtil.Math.toFlatVec3(physics.normDirection)

	# No initial angle needed when shooting straight up or down or when we dont have gravity for some reason
	if direction.is_zero_approx() or _gravity <= 0.0:
		_velocity = physics.normDirection * physics.FLAT_SPEED

		return
	
	var directionLength := direction.length()
	direction /= directionLength

	# Derivation of the formula:
	#
	# We assume that our arrow starts at x,y = 0,0, therefore:
	# y(t) = verticalDist = verticalVel * t - 1/2 * gt^2
	# x(t) = horizontalDist = horizontalVel * t
	#
	# Where there are two equations with the unknowns verticalVel and t
	# t is irrelevant, as we are solving for verticalVel. Therefore:
	# t = horizontalDist / horizontalVel
	# verticalDist = verticalVel * horizontalDist / horizontalVel - 1/2 * g (horizontalDist / horizontalVel)^2
	# (verticalDist + 1/2 * g (horizontalDist / horizontalVel)^2) / (horizontalDist / horizontalVel) = verticalVel

	var horizontalDist := physics.distance * directionLength
	var verticalDist := physics.distance * physics.normDirection.y

	var time := horizontalDist / physics.FLAT_SPEED

	_velocity = Vector3(
		direction.x * physics.FLAT_SPEED,
		(verticalDist + 0.5 * physics.GRAVITY * time * time) / time,
		direction.z * physics.FLAT_SPEED
	)


func _tick(delta : float) -> void:
	_velocity.y -= _gravity * delta

#endregion
