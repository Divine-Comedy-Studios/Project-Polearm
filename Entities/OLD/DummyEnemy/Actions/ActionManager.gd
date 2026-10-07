extends EntityActionManager
class_name DummyEnemyActionManager


#region Scene members

@export var controller : DummyEnemyController = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(entity is DummyEnemy, "DummyEnemyActionManager._ready(): The entity must be a DummyEnemy!")
	assert(controller != null, "DummyEnemyActionManager._ready(): Controller not assigned!")

	init()

#endregion


#region Override functions

func insertState(child : Node) -> void:
	if child is DummyEnemyAction:
		child.init(self)
		_addState(child)

func _initialState() -> StringName:
	return DummyEnemyAction.Type.idle

#endregion


#region Public functions

func pushActionQueue(queue : StringName) -> void:
	_actionQueue = queue

func popActionQueue() -> StringName:
	var queue := _actionQueue
	_actionQueue = DummyEnemyAction.Type.none
	return queue


func pushActionForced(queue : StringName) -> void:
	_actionForced = queue

func popActionForced() -> StringName:
	var queue := _actionForced
	_actionForced = DummyEnemyAction.Type.none
	return queue

#endregion


#region Private functions

# Input processing by sorting them by priority
#func _processInputs():
#	if _actionForced != DummyEnemyAction.Type.none:
#		controller.intents.actions = [ popActionForced() ]

#	else:
#		_processActionQueue()
#		_processAerialStates()
#
#		# Sort current inputs
#		controller.intents.actions.sort_custom(hasHigherPriority)


#func _processActionQueue() -> void:
#	if (_actionQueue != DummyEnemyAction.Type.none and
#		not controller.intents.actions.has(_actionQueue)):
#		controller.intents.actions.push_back(_actionQueue)
#		_actionQueue = DummyEnemyAction.Type.none

#endregion
