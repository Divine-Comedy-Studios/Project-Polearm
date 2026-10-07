@tool extends Hurtbox

@export var characterBody: CharacterBody3D

func recieveHit(hitData: HitboxData) -> void:
	# Optional knockback before dying (useful if kill() plays a death animation)
	characterBody.takeDamage(hitData.directionalForce)
