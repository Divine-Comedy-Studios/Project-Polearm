@tool

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

func recieveHit(data : HitboxData) -> void:
	_resources.takeDamage(data)

func kill() -> void:
	print("[KILL] 2/4 EntityHurtbox.kill() reached, resources = ", _resources) # DEBUG
	_resources.kill()

#endregion
