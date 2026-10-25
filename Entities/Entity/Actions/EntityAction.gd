extends BasicState
class_name EntityAction


#region Helper classes

class Type:
	# These types are all general states which are universal across all entities

	const none := TYPE_NONE

	const idle := &"idle"
	const damage := &"damage"

#endregion


#region Exported variables

@export_group("General")
@export var TYPE : StringName
@export var PRIORITY : int = 0

@export_group("Gameplay")
@export var REPEATABLE : bool = false # A repeatable state can get triggered multiple times in succession
@export var ENERGY_COST : float = 0
@export var PLAY_SFX : bool = false

#endregion


#region Scene members

var _context : EntityActionManager

#endregion


#region Member variables

# Animation data
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

# Root motion

var rootMotionEnabled : bool = true


# Sound effects

var _lastSFX : SFXData.Type = SFXData.Type.none

#endregion


#region Override functions

# This is executed on action enter
func enter() -> void:
	rootMotionEnabled = true # Always enable root motion when entering a state

	_enter()

	_context.resources.pay(self) # The action is pretty much guaranteed to be payable at this point, if not, not a big deal


# This is executed on action exit and resets the action to prepare it for the next time it's activated
func exit() -> void:
	_exit()
	
	frameDataScale = 1.0
	_progress = 0
	_lastSFX = SFXData.Type.none

	if _context.weapon:
		_context.weapon.disable()


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
	_processSFX()

	_progress += delta * frameDataScale


# Action switching behavior
func nextAction() -> StringName:
	_preprocessActions()

	if not _context.frameData.transitionable(data.ANIMATION_NAME, _progress):
		return Type.none

	return _nextAction()


# Checks if a given action can be considered for the next one
func actionViability(action : EntityAction, checkSelfLowerability : bool = true) -> int:
	# If both animations have the same type, just ignore it and break
	if action.TYPE == TYPE and not REPEATABLE:
		return -1

	if not _context.resources.payable(action):
		return 0

	if action.PRIORITY == 0: # Actions with a 0 priority are automatically considered "passive states", i.e. they will not actively try to fight for the current state
		if not finished():
			return 0

	if checkSelfLowerability and action.PRIORITY < PRIORITY:
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
	return _context.frameData.finished(data.ANIMATION_NAME, _progress) or _context.animator.animation(data.ANIMATION_FULL_NAME).loop_mode != Animation.LOOP_NONE


# Explicit definition of higher priority

static func hasHigherPriority(first : EntityAction, second : EntityAction) -> bool:
	return first.PRIORITY > second.PRIORITY

func hasHigherPriorityThan(second : StringName) -> bool:
	return PRIORITY > (_context.action(second) as EntityAction).PRIORITY

#endregion


#region Private functions

# Gets the highest priority action from the current input
func _highestPriorityAction(actions : Array[StringName]) -> StringName:
	var candidate := Type.none

	# Go through all higher priority actions and immediately return them if possible as they can cancel the current action
	for actionType : StringName in actions:
		var action := _context.action(actionType) as EntityAction
		var viability := actionViability(action) # 0 == unviable, -1 == same action, 1 == possibly viable

		# These checks here occur due to a tiebreaker when there are multiple actions with the same priority
		if viability == 1:
			if action.PRIORITY != PRIORITY:
				return actionType if candidate == Type.none else candidate

			candidate = actionType
		elif viability == -1: # If the same action has been found, return the last candidate
			return candidate

	return Type.none


func _processWeapon() -> void:
	if _context.weapon != null:
		if _context.frameData.weaponActivate(data.ANIMATION_NAME, _progress):
			if not _context.weapon.enabled():
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
	if not rootMotionEnabled:
		return
	if not data.ROOT_MOTION:
		return

	var entityQuaternion := _context.entity.get_quaternion()
	var rootQuaternion := _context.animator.rootOrientation

	_context.entity.set_quaternion(entityQuaternion * _context.animator.get_root_motion_rotation())
	_context.entity.setMovement((
		rootQuaternion.inverse() * _context.animator.get_root_motion_rotation_accumulator().inverse() *
		entityQuaternion.inverse() 
	) * _context.animator.get_root_motion_position() / delta)


func _processSFX() -> void:
	if not PLAY_SFX:
		return

	var currentSFX := _context.frameData.sfx(data.ANIMATION_NAME, _progress)

	if currentSFX == _lastSFX:
		return

	Globals.sfxManager.play(currentSFX, _processSFXPosition(), 1.0)
	_lastSFX = currentSFX

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


func _processSFXPosition() -> Vector3:
	return _context.entity.global_position

#endregion
