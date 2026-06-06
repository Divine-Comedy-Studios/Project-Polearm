extends BasicState
class_name EntityAction


#region Helper classes

class Type:
	# These types are all general states which are universal across all entities

	const none := TYPE_NONE

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

var _context : EntityActionManager

#endregion


#region Member variables

@export var data : EntityActionData = null
var frameDataScale : float = 1.0

var payload : Variant = null:
	get:
		var tmp = payload
		payload = null
		return tmp
	set(value):
		payload = value


var _progress : float

#endregion


#region Override functions

# This is executed on action enter
func enter() -> void:
	if _context.combatManager.isNextComboAction(TYPE):
		data = _context.combatManager.registerComboAction(TYPE)
	else:
		_context.combatManager.resetActiveCombo()

	_context.resources.pay(self) # The action is pretty much guaranteed to be payable at this point, if not, not a big deal

	_enter()

# This is executed on action exit and resets the action to prepare it for the next time it's activated
func exit() -> void:
	_exit()
	
	_progress = 0
	frameDataScale = 1.0


func type() -> StringName:
	return TYPE

#endregion


#region Public funcitons

func init(manager : EntityActionManager) -> void:
	_context = manager

	_implInit()


func tick(delta : float) -> void:
	_processWeapon()
	_processDirection(delta)
	_tick(delta)
	_processRootMotion(delta)

	_progress += delta * frameDataScale


# Action switching behavior
func nextAction() -> StringName:
	_preprocessActions()

	if not _context.frameData.transitionable(data.ANIMATION_NAME, _progress):
		return Type.none

	return _nextAction()


# Checks if a given action can be considered for the next one
func actionViability(action : EntityAction) -> int:
	# If both animations have the same type, just ignore it and break
	if action.TYPE == TYPE and not REPEATABLE:
		return -1

	if not _context.resources.payable(action):
		return 0

	if action.PRIORITY < PRIORITY:
		if _context.frameData.nonLowerable(data.ANIMATION_NAME, _progress): # Excecution order of if statements in GDScript is always a bit funny
			return 0
	if not action._viable():
		return 0

	return 1


func interrupt(actionType : StringName) -> StringName:
	return actionType


# Frame data interface

func interruptable() -> bool:
	return _context.frameData.interruptable(data.ANIMATION_NAME, _progress)

func finished() -> bool:
	return _context.frameData.finished(data.ANIMATION_NAME, _progress) and _context.animator.animation(data.ANIMATION_FULL_NAME).loop_mode == Animation.LOOP_NONE


# Explicit definition of higher priority

static func hasHigherPriority(first : EntityAction, second : EntityAction) -> bool:
	return first.PRIORITY > second.PRIORITY

func hasHigherPriorityThan(second : StringName) -> bool:
	return PRIORITY > (_context.action(second) as EntityAction).PRIORITY

#endregion


#region Private functions

func _processWeapon() -> void:
	if _context.weapon != null:
		if _context.frameData.weaponActivate(data.ANIMATION_NAME, _progress):
			_context.weapon.enable(data.HIT_DATA)
		elif _context.weapon.enabled():
			_context.weapon.disable()


# If enabled, this will influence the direction the player faces using the direction of the input package
func _processDirection(delta : float) -> void:
	var rotationTrackingSpeed := _context.frameData.rotationTracking(data.ANIMATION_NAME, _progress) * delta
	if rotationTrackingSpeed != 0.0:
		_context.entity.rotate_y(clampf(_processDirectionAngle(), -rotationTrackingSpeed, rotationTrackingSpeed))

# If enabled, this will add root motion to the animation
func _processRootMotion(delta : float) -> void:
	if not data.ROOT_MOTION:
		return

	var entityQuaternion := _context.entity.get_quaternion()
	var rootQuaternion := _context.animator.rootOrientation

	_context.entity.set_quaternion(entityQuaternion * _context.animator.get_root_motion_rotation())
	_context.entity.setMovement((
		rootQuaternion.inverse() * _context.animator.get_root_motion_rotation_accumulator().inverse() *
		entityQuaternion.inverse() 
	) * _context.animator.get_root_motion_position() / delta)

#endregion


#region Implementation & Virtual functions

func requestAction() -> StringName:
	return Type.none


func _viable() -> bool:
	return true


func _implInit() -> void:
	pass


func _enter() -> void:
	pass

func _exit() -> void:
	pass


@warning_ignore("unused_parameter")
func _tick(delta : float) -> void:
	pass


func _preprocessActions() -> void:
	pass

func _nextAction() -> StringName:
	return Type.none


func _processDirectionAngle() -> float:
	return 0.0

#endregion
