class_name GameObject
extends Node3D


#region Enums

enum Type {
	none,

	# Entities

	player,

	enemy = 10,

	dummyEnemy = 20,
	beanEnemy,

	solider = 30,
	heavySolider,
	ninja,

	archer = 50,
	heavyArcher,
	chainArcher,

	# Objects

	arrow = 100,
	homingMissile,
}

#endregion


#region Member variables

var _pool : GameObjectPool = null

#endregion


#region Public functions

# Called from the entity the handle references
func kill() -> void:
	_kill()

	_pool.remove_child(self)
	_pool.active.erase(entityID())
	_pool.pooled.push_back(self)


func entityID() -> int:
	return get_instance_id()

#endregion


#region Virtual functions

# Calls the spawn function of the entity
@warning_ignore("unused_parameter")
func spawn(payload : Variant) -> void:
	pass

func _kill() -> void:
	pass

#region
