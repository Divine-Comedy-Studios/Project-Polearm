@tool

extends Weapon
class_name Projectile


#region Scene members

@export var _hurtbox : Area3D = null

#endregion


#region Member variables

var handle : ProjectileHandle = null

var _remainingLifetime : float = 0.0
var _velocity : Vector3 = Vector3.ZERO

var _alive : bool = false

#endregion


#region Built-in functions

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	assert(_hurtbox != null, "Projectile._ready(): Hurtbox not assigned!")

	_hurtbox.area_entered.connect(_killWrapper)
	_hurtbox.body_entered.connect(_killWrapper)


func _physics_process(delta : float) -> void:
	if Engine.is_editor_hint():
		return

	_tick(delta)
	global_position += _velocity * delta

	_faceDirection(_velocity)

	_remainingLifetime -= delta
	if _remainingLifetime <= 0.0:
		_killWrapper(null)

#endregion


#region Public functions

func spawn(physics : ProjectilePhysics):
	assert(not physics.normDirection.is_zero_approx(), "Projectile.spawn(): Direction must not be zero!")

	process_mode = Node.PROCESS_MODE_INHERIT
	position = physics.position

	_remainingLifetime = physics.LIFETIME
	_alive = true

	_spawn(physics)

	enable()


func kill() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

	disable()

	if handle == null:
		queue_free()

#endregion


#region Private functions

func _faceDirection(direction : Vector3) -> void:
	if direction.is_zero_approx():
		return

	look_at(
		global_position + direction,
		Vector3.UP if absf(direction.normalized().dot(Vector3.UP)) < 0.999 else Vector3.FORWARD
	)


func _killWrapper(_param : Variant) -> void:
	if not _alive:
		return
	
	_alive = false

	if is_inside_tree():
		await get_tree().process_frame

	handle.kill()

#endregion


#region Virtual functions

@warning_ignore("unused_parameter")
func _spawn(physics : ProjectilePhysics) -> void:
	pass


@warning_ignore("unused_parameter")
func _tick(delta : float) -> void:
	pass

#endregion
