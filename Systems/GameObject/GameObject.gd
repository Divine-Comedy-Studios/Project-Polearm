class_name GameObject


#region Enums

enum Type {
	none = 0,

	entity = 1 << 0,
	player = entity + (1 << 1),

	enemy = entity + (1 << 4),
	dummyEnemy = enemy + (1 << 5),
	solider = enemy + (1 << 6)
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
	_pool.active.erase(object.get_instance_id())

	_killImpl()


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

func _killImpl() -> void: # May be left empty for most use cases
	pass


@warning_ignore("unused_parameter")
func tick(delta : float, payload : Variant = null) -> void:
	pass

#region
