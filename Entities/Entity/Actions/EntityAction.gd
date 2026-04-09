@warning_ignore_start("unused_parameter")

extends BasicState
class_name EntityAction


#region Helper classes

class Type:
	# These types are all general states which are universal across all entities

	const none := NONE_TYPE

	const idle := &"idle"
	const damage := &"dmg"

#endregion


#region Exported variables

@export_group("General")
@export var TYPE : StringName
@export var PRIORITY : int = 0

@export_group("Gameplay")
@export var REPEATABLE : bool = false # A repeatable state can get triggered multiple times in succession
@export var ENERGY_COST : float = 0

#endregion


#region Scene members

var context : EntityActionManager

#endregion


#region Member variables

@export var data : EntityActionData = null

var _progress : float

#endregion


#region Public funcitons

func init(manager : EntityActionManager) -> void:
	context = manager

	_implInit()


func tick(delta : float) -> void:
	_processDirection(delta)
	_tick(delta)
	_processRootMotion(delta)

	_progress += delta


# Action switching behavior
func nextAction() -> StringName:
	_processActions()

	if not context.frameData.transitionable(data.ANIMATION_NAME, _progress):
		return Type.none

	return _nextAction()


# Checks if a given action can be considered for the next one
func actionViability(action : EntityAction) -> int:
	# If both animations have the same type, just ignore it and break
	if action.TYPE == TYPE and not REPEATABLE:
		return -1
	
	if context.resources.payable(action):
		if _implActionViable(action):
			return 1

	return 0


# Interrupt immediately triggers a state switch aslong as the priority of the interrupt is higher than the priority of the current state
func interrupt(actionType : StringName) -> StringName:
	var action := context.action(actionType) as EntityAction

	if hasHigherPriority(action, self):
		return actionType
	
	return Type.none


# Explicit definition of higher priority

static func hasHigherPriority(first : EntityAction, second : EntityAction) -> bool:
	return first.PRIORITY > second.PRIORITY

func hasHigherPriorityThan(second : StringName) -> bool:
	return PRIORITY > (context.action(second) as EntityAction).PRIORITY

#endregion


#region Private functions

# If enabled, this will influence the direction the player faces using the direction of the input package
func _processDirection(delta : float) -> void:
	var rotationTrackingSpeed := context.frameData.rotationTracking(data.ANIMATION_NAME, _progress) * delta
	if not is_zero_approx(rotationTrackingSpeed):
		context.entity.rotate_y(clampf(_processDirectionAngle(), -rotationTrackingSpeed, rotationTrackingSpeed))

# If enabled, this will add root motion to the animation
func _processRootMotion(delta : float) -> void:
	if not data.ROOT_MOTION:
		return
	
	var entityQuaternion := context.entity.get_quaternion()
	var rootQuaternion := context.animationPlayer.rootOrientation

	context.entity.set_quaternion(rootQuaternion.inverse() * entityQuaternion * context.animationPlayer.get_root_motion_rotation())
	context.entity.velocity = (
		context.animationPlayer.get_root_motion_rotation_accumulator().inverse() *
		rootQuaternion * entityQuaternion
	) * context.animationPlayer.get_root_motion_position() / delta

#endregion


#region Override functions

# This is executed on action enter
func enter() -> void:
	if context.combatManager.isNextComboAction(TYPE):
		data = context.combatManager.registerComboAction(TYPE)

	context.resources.pay(self) # The action is pretty much guaranteed to be payable at this point, if not, not a big deal
	context.animationPlayer.play(data.ANIMATION_FULL_NAME)
	
	_enter()

# This is executed on action exit and resets the action to prepare it for the next time it's activated
func exit() -> void:
	_exit()
	
	_progress = 0


func type() -> StringName:
	return TYPE

#endregion


#region Implementation & Virtual functions

func _implInit() -> void:
	pass

func _tick(delta : float) -> void:
	pass


func _enter() -> void:
	pass

func _exit() -> void:
	pass


func _processActions() -> void:
	pass

func _nextAction() -> StringName:
	return Type.none

func _implActionViable(action : EntityAction) -> bool:
	return true


func _processDirectionAngle() -> float:
	return 0.0

#endregion
