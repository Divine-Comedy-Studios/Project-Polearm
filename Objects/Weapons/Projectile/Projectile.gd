@tool

extends GameObject
class_name Projectile


#region Scene members

@export var hitbox : Hitbox = null

#endregion


#region Member variables

var _remainingLifetime : float = 0.0
var _velocity : Vector3 = Vector3.ZERO

var _alive : bool = false

#endregion


#region Built-in functions

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	assert(hitbox != null, "Projectile._ready(): Hitbox not assigned!")


func _physics_process(delta : float) -> void:
	if Engine.is_editor_hint():
		return

	_tick(delta)
	global_position += _velocity * delta

	_faceDirection(_velocity)

	_remainingLifetime -= delta
	if _remainingLifetime <= 0.0:
		kill()

#endregion


#region Implementation functions

func spawn(payload : Variant):
	assert(payload is ProjectilePhysics, "ArrowHandle.spawn(): Wrong payload type!")

	var physics := payload as ProjectilePhysics
	assert(not physics.normDirection.is_zero_approx(), "Projectile.spawn(): Direction must not be zero!")

	position = physics.position

	_remainingLifetime = physics.LIFETIME
	_alive = true

	_spawn(physics)

	hitbox.enable()


func kill() -> void:
	if _alive: # This prevents the projectile from killing itself multiple times in a row
		_alive = false
		super.kill()


func _kill() -> void:
	hitbox.disable()

	if _pool == null:
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

#endregion


#region Virtual functions

@warning_ignore("unused_parameter")
func _spawn(physics : ProjectilePhysics) -> void:
	pass


@warning_ignore("unused_parameter")
func _tick(delta : float) -> void:
	pass

#endregion


#region Signal functions

func _onHurtboxCollided(_body: Node3D) -> void:
	if is_inside_tree():
		await get_tree().process_frame

	kill()

#endregion
