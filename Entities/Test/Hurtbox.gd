extends Hurtbox

@export var characterBody: CharacterBody3D

func recieveHit(hitData: HitboxData) -> void:
	characterBody.applyForce(hitData.directionalForce)
