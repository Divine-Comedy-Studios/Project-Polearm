extends Entity
class_name BasicEnemy


#region Scene members

@export_group("Scene members")
@export var _controller : BasicEnemyController = null

#endregion


#region Member variables

var _needsReset : bool = false

#endregion


#region Built-in functions

func _ready() -> void:
	super._ready()

	assert(_controller != null, "BasicEnemy._ready(): Controller not assigned!")

	actionManager.killed.connect(kill)

#endregion


#region Public functions

func tick(delta : float, payload : EnemyPerception.Data) -> void:
	_controller.tick(delta, payload)


func role() -> EnemyManager.Role:
	return _controller.currentRole

func availableRoles() -> Array[EnemyManager.Role]:
	return _controller.AVAILABLE_ROLES

func requestRoleChange() -> bool:
	return _controller.requestRoleChange

func position() -> Vector3:
	return actionManager.entity.global_position

#endregion


#region Override functions

@warning_ignore("unused_parameter")
func _spawn(payload : Variant) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT

	Globals.enemyManager.register(self)

	if _needsReset:
		actionManager.reset()
		_needsReset = false


func _kill() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	_needsReset = true

	Globals.enemyManager.unregister(self)

	if _pool == null:
		queue_free()

#endregion
