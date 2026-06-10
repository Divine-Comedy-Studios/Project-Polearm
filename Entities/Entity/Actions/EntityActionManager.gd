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

@onready var combatManager := $"CombatManager" as EntityCombatManager

#endregion


#region Member variables

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
	assert(entity != null, "EntityActionManager._ready(): Entity physics body not assigned!")

	assert(resources != null, "EntityActionManager._ready(): Entity resources not assigned!")
	assert(frameData != null, "EntityActionManager._ready(): Entity frame data not assigned!")

	assert(combatManager != null, "EntityActionManager._ready(): Entity combat manager not assigned!")

	assert(animator != null, "EntityActionManager._ready(): Entity animator not assigned!")

	super.init()

func vulnerable() -> bool:
	return true


func hasHigherPriority(a : StringName, b : StringName) -> bool:
	return EntityAction.hasHigherPriority(action(a) as EntityAction, action(b) as EntityAction)

#endregion
