extends BasicStateMachine
class_name EntityActionManager


#region Scene members

@export_group("Scene members")
@export var entity : Node3D = null
@export var frameData : EntityFrameData = null
@export var resources : EntityResources = null
@export var animator : EntityAnimator = null
@export var hurtbox : Hurtbox = null
@export var weapon : Weapon = null

#endregion


#region Member variables

# Action modification

var _actionForced : StringName = EntityAction.Type.none
var _actionQueue : StringName = EntityAction.Type.none


# Next action payload

var payload : Variant = null:
	get:
		var tmp = payload
		payload = null
		return tmp
	set(value):
		payload = value

#endregion


#region Override functions

func tick(delta: float) -> void:
	update()
	currentState.tick(delta)


func _interruptState(type : StringName) -> StringName:
	var current := currentState as EntityAction
	var next : StringName = current.interrupt(type)
	if next != EntityAction.Type.none:
		payload = current.payload

	return next

func _nextState() -> StringName:
	var current := currentState as EntityAction
	var next : StringName = current.nextAction()
	if next != EntityAction.Type.none:
		payload = current.payload

	return next

#endregion


#region Public functions

func init() -> void:
	assert(entity != null, "EntityActionManager._ready(): Entity entity not assigned!")

	assert(resources != null, "EntityActionManager._ready(): Entity resources not assigned!")
	assert(frameData != null, "EntityActionManager._ready(): Entity frame data not assigned!")

	assert(animator != null, "EntityActionManager._ready(): Entity animator not assigned!")

	super.init()


func reset() -> void:
	currentState.exit()

	entity.transform = Transform3D.IDENTITY
	hurtbox.enable()
	resources.reset()
	animator.reset()
	_reset()

	_enterState(_initialState())


# Action queue & forced lookup

func pushActionQueue(queue : StringName) -> void:
	_actionQueue = queue

func popActionQueue() -> StringName:
	var queue := _actionQueue
	_actionQueue = EntityAction.Type.none
	return queue


func pushActionForced(queue : StringName) -> void:
	_actionForced = queue

func popActionForced() -> StringName:
	var queue := _actionForced
	_actionForced = EntityAction.Type.none
	return queue


# Entity state

func vulnerable() -> bool:
	return hurtbox.enabled()

# Utility

func hasHigherPriority(a : StringName, b : StringName) -> bool:
	return EntityAction.hasHigherPriority(action(a) as EntityAction, action(b) as EntityAction)

#endregion


#region Private functions

func _processActions(actions : Array[StringName]):
	if _actionForced != PlayerAction.Type.none:
		actions = [ popActionForced() ]
		
	else:
		_processActionQueue(actions)
		_implProcessActions(actions)

		# Sort current inputs
		actions.sort_custom(hasHigherPriority)


func _processActionQueue(actions : Array[StringName]) -> void:
	if (_actionQueue != EntityAction.Type.none and
		not actions.has(_actionQueue)):
		actions.push_back(_actionQueue)
		_actionQueue = EntityAction.Type.none

#endregion


#region Override functions

@warning_ignore("unused_parameter")
func _implProcessActions(actions : Array[StringName]) -> void:
	pass

func _reset() -> void:
	pass

#endregion
