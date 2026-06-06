extends CharacterBody3D

const FRICTION = 10.0

func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta
    else:
        # Apply friction on the floor only
        velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
        velocity.z = move_toward(velocity.z, 0.0, FRICTION * delta)

    move_and_slide()

func applyForce(direction: Vector3) -> void:
    velocity += direction
