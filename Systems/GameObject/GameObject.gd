class_name GameObject


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

var object : Node = null

var _pool : GameObjectPool = null

#endregion


#region Built-in functions

func _init(obj : Node, pool : GameObjectPool) -> void:
	object = obj
	_pool = pool

	_initImpl()

#endregion


#region Public functions

# Called from the entity the handle references
func kill() -> void:
	_pool.remove_child(object)
	_pool.active.erase(entityID())
	_pool.pooled.push_back(self)

	_kill()


func entityID() -> int:
	return object.get_instance_id()

#endregion


#region Virtual functions

func _initImpl() -> void:
	pass

# Calls the spawn function of the entity
@warning_ignore("unused_parameter")
func spawn(payload : Variant) -> void:
	pass

func _kill() -> void:
	pass


@warning_ignore("unused_parameter")
func tick(delta : float, payload : Variant = null) -> void:
	pass

#region
