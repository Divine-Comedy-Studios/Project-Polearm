extends EntityActionManager
class_name BasicEnemyActionManager


#region Signals

signal killed # Emitted by the death action once the death animation is over

#endregion


#region Scene members

@export_group("Scene members")
@export var controller : BasicEnemyController = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(controller != null, "BasicEnemyActionManager._ready(): Controller not assigned!")

	init()

func _physics_process(delta : float) -> void:
	_processActions(controller.intents.actions)

	tick(delta)

#endregion


#region Override functions

func insertState(child : Node) -> void:
	if child is BasicEnemyAction:
		child.init(self)
		_addState(child)

func _initialState() -> StringName:
	return BasicEnemyAction.Type.idle

#endregion


#region Public functions

func kill() -> void:
	killed.emit()

func reset() -> void:
	currentState.exit()

	resources.reset()
	controller.reset()
	animator.reset()
	_reset()

	_enterState(_initialState())

#endregion


#region Virtual functions

func _reset() -> void:
	pass

#endregion
