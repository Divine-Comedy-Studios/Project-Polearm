extends Hurtbox
class_name EntityHurtbox


#region Scene members

@export var _resources : EntityResources = null

#endregion


#region Built-in funcitons

func _ready() -> void:
	assert(_resources != null, "EntityHurtbox._ready(): Entity resources not assigned!")

	super._ready()

#endregion


#region Implementation functions

func _implHit(hitbox : Hitbox) -> void:
	_resources.takeDamage(hitbox.data)

#endregion
