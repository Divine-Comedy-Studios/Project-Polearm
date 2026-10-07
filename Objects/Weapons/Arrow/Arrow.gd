@tool

extends Weapon
class_name Arrow


#region Scene members

@export var _hurtbox : Hurtbox = null

#endregion


#region Member variables

var handle : GameObject = null

var _remainingLifetime : float = 0.0

var _velocity : Vector3 = Vector3.ZERO
var _gravity : float = 0.0

var _hitData : HitboxData = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(_hurtbox != null, "Arrow._ready(): Hurtbox not assigned!")

	_hurtbox.area_entered.connect(kill)
	_hurtbox.body_entered.connect(kill)


func _physics_process(delta : float) -> void:
	if not Engine.is_editor_hint():
		_velocity.y -= _gravity * delta
		global_position += _velocity * delta

		look_at(global_position + _velocity)

		_remainingLifetime -= delta
		if _remainingLifetime <= 0.0:
			kill()

#endregion


#region Public functions

# Called by the handle. The physics resource is shared between all arrows of a shooter, and the shooter changes
# it with every shot, so everything needed is copied here instead of keeping a reference to it.
func spawn(physics : ArrowPhysics) -> void:
	assert(not physics.normDirection.is_zero_approx(), "Arrow.spawn(): Direction must not be zero!")

	process_mode = Node.PROCESS_MODE_INHERIT
	position = physics.position

	_gravity = physics.GRAVITY
	_hitData = physics.HIT_DATA
	_remainingLifetime = physics.LIFETIME

	_velocity = _calculateLaunchVelocity(physics)

	enable()


func kill() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

	if handle != null:
		handle.kill()
	else:
		queue_free()

#endregion


#region Private functions

func _calculateLaunchVelocity(physics : ArrowPhysics) -> Vector3:
	var direction := PPUtil.Math.toFlatVec3(physics.normDirection)

	# No initial angle needed when shooting straight up or down or when we don't have gravity for some reason
	if direction.is_zero_approx() or _gravity <= 0.0:
		return physics.normDirection * physics.SPEED

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

	var horizontalDist := physics.distance * direction.length()
	var verticalDist := physics.distance * physics.normDirection.y

	var time := horizontalDist / physics.FLAT_SPEED

	return Vector3(
		direction.x * physics.FLAT_SPEED,
		(verticalDist + 0.5 * physics.GRAVITY * time * time) / time,
		direction.z * physics.FLAT_SPEED
	)

#endregion
