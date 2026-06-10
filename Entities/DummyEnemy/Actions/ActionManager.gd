extends EntityActionManager
class_name DummyEnemyActionManager


#region Scene members

@export var controller : DummyEnemyController = null

#endregion


#region Member variables

var _actionForced : StringName = DummyEnemyAction.Type.none
var _actionQueue : StringName = DummyEnemyAction.Type.none

#endregion


#region Built-in functions

func _ready() -> void:
	assert(entity is DummyEnemy, "DummyEnemyActionManager._ready(): The entity must be a DummyEnemy!")
	assert(controller != null, "DummyEnemyActionManager._ready(): Controller not assigned!")

	init()


func _physics_process(delta: float) -> void:
	_processInputs()

	tick(delta)

	entity.tick(delta)

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

func vulnerable() -> bool:
	return hurtbox.enabled()

#endregion


#region Private functions

# Input processing by sorting them by priority
func _processInputs():
	if _actionForced != DummyEnemyAction.Type.none:
		controller.intents.actions = [ popActionForced() ]

	else:
		_processActionQueue()
		_processAerialStates()

		# Sort current inputs
		controller.intents.actions.sort_custom(hasHigherPriority)


func _processActionQueue() -> void:
	if (_actionQueue != DummyEnemyAction.Type.none and
		not controller.intents.actions.has(_actionQueue)):
		controller.intents.actions.push_back(_actionQueue)
		_actionQueue = DummyEnemyAction.Type.none


func _processAerialStates() -> void:
	var aerialInputs : Array[StringName] = []
	for input : StringName in controller.intents.actions:
		var aerial := DummyEnemyAction.Type.TO_AIR.get(input, DummyEnemyAction.Type.none) as StringName
		if aerial == DummyEnemyAction.Type.none:
			continue
		if aerialInputs.has(aerial):
			continue

		aerialInputs.push_back(aerial)

	controller.intents.actions = aerialInputs

#endregion
