extends CharacterBody3D

@export var enemy : CubeEnemy = null

@export var move_speed: float = 3.0
@export var acceleration: float = 12.0
@export var turn_speed: float = 8.0

@export_group("Randomness")
## Each enemy's speed is multiplied by a random value in [1 - variance, 1 + variance].
@export_range(0.0, 0.9) var speed_variance: float = 0.25
## Random delay (seconds) before the enemy starts chasing after spawning.
@export var reaction_delay_range: Vector2 = Vector2(0.0, 1.0)
## Max angle (degrees) the path can veer off the straight line to the player.
@export_range(0.0, 90.0) var weave_angle_degrees: float = 35.0
## How long (seconds) a weave direction is held before picking a new one.
@export var weave_interval_range: Vector2 = Vector2(0.6, 1.8)
## Chance per second to stop and hesitate briefly.
@export_range(0.0, 1.0) var hesitate_chance_per_second: float = 0.1
## How long (seconds) a hesitation lasts.
@export var hesitate_duration_range: Vector2 = Vector2(0.3, 0.9)
## Weaving fades out when closer than this distance, so the enemy still reaches the player.
@export var weave_fade_distance: float = 3.0

const FRICTION = 10.0

var player: Node3D = null

var _speed: float
var _reaction_timer: float
var _weave_angle: float = 0.0
var _weave_timer: float = 0.0
var _hesitate_timer: float = 0.0


func _ready() -> void:
	_speed = move_speed * randf_range(1.0 - speed_variance, 1.0 + speed_variance)
	_reaction_timer = randf_range(reaction_delay_range.x, reaction_delay_range.y)


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	_find_player()
	_update_randomness(delta)

	var can_chase := player != null and _reaction_timer <= 0.0 and _hesitate_timer <= 0.0

	if is_on_floor():
		if can_chase:
			_chase(delta)
		else:
			# Waiting, hesitating or no target: slow down
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
			velocity.z = move_toward(velocity.z, 0.0, FRICTION * delta)

	move_and_slide()


func _find_player() -> void:
	if player != null and is_instance_valid(player):
		return
	player = get_tree().get_first_node_in_group("Player") as Node3D


func _update_randomness(delta: float) -> void:
	# Initial reaction delay
	if _reaction_timer > 0.0:
		_reaction_timer -= delta
		return

	# Hesitation: count down, or randomly start one
	if _hesitate_timer > 0.0:
		_hesitate_timer -= delta
	elif randf() < hesitate_chance_per_second * delta:
		_hesitate_timer = randf_range(hesitate_duration_range.x, hesitate_duration_range.y)

	# Pick a new weave offset every so often
	_weave_timer -= delta
	if _weave_timer <= 0.0:
		_weave_angle = deg_to_rad(randf_range(-weave_angle_degrees, weave_angle_degrees))
		_weave_timer = randf_range(weave_interval_range.x, weave_interval_range.y)


func _chase(delta: float) -> void:
	# Flat direction towards the player (ignore height difference)
	var to_player := player.global_position - global_position
	to_player.y = 0.0
	if to_player.length_squared() < 0.0001:
		return

	var distance := to_player.length()
	var direction := to_player / distance

	# Veer off the straight line, less so the closer we get
	var weave_strength := clampf(distance / weave_fade_distance, 0.0, 1.0)
	direction = direction.rotated(Vector3.UP, _weave_angle * weave_strength)

	# Accelerate towards the target velocity instead of setting it directly,
	# so knockback from applyForce() still has an effect and fades out.
	var target := direction * _speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)

	# Smoothly face the direction of travel
	var target_yaw := atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, turn_speed * delta)


func takeDamage(direction: Vector3) -> void:
	velocity += direction
	enemy.health -= 1
