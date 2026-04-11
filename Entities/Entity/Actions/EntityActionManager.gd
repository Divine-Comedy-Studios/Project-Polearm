extends BasicStateMachine
class_name EntityActionManager


#region Scene members

@export var entity : PhysicsBody3D = null

@export var frameData : EntityFrameData = null
@export var resources : EntityResources = null

@export var combatManager : EntityCombatManager = null

@export var animator : EntityAnimator = null

#endregion


#region Built-in functions

func tick(delta: float) -> void:
	update()
	currentState.tick(delta)

#endregion


#region Public functions

func init() -> void:
	assert(entity != null, "EntityActionManager._ready(): Entity physics body not assigned!")

	assert(resources != null, "EntityActionManager._ready(): Entity resources not assigned!")
	assert(frameData != null, "EntityActionManager._ready(): Entity frame data not assigned!")

	assert(combatManager != null, "EntityActionManager._ready(): Entity combat manager not assigned!")

	assert(animator != null, "EntityActionManager._ready(): Entity animator not assigned!")

	super.init()


func hasHigherPriority(a : StringName, b : StringName) -> bool:
	return EntityAction.hasHigherPriority(action(a), action(b))

#endregion


#region Override functions

func _interruptState(type : StringName) -> StringName:
	return entity.interrupt(type)


func _nextState() -> StringName:
	return currentState.nextAction()

#endregion
