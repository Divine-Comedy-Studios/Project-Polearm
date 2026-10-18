extends Entity
class_name BasicEnemy


#region Scene members

@export_group("Scene members")
@export var _controller : BasicEnemyController = null

#endregion


#region Member variables

var handle : BasicEnemyHandle = null

var _needsReset : bool = false

#endregion


#region Built-in functions

func _ready() -> void:
	super._ready()

	assert(_controller != null, "BasicEnemy._ready(): Controller not assigned!")

	actionManager.killed.connect(handle.kill)

#endregion


#region Public functions

func tick(delta : float, payload : EnemyPerception.Data) -> void:
	_controller.tick(delta, payload)


func kill() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	_needsReset = true

	if handle == null:
		queue_free()


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

func _spawn() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT

	if _needsReset:
		_reset()

#endregion


#region Private functions

func _reset() -> void:
	actionManager.reset()

#endregion
