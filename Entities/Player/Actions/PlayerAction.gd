extends Node
class_name PlayerAction


#region Enums

enum Type {
	none,
	

	# Idle
	idle,
	

	# Ground movement actions
	walk,
	run,
	sprint,
	

	# Jumping
	jumpBasic,
	jumpStill, jumpRun, jumpSprint,

	fall,

	# The landing animation can always determined, hence it needs no intermediate action
	landingStill, landingRun,
	

	# Dodge states
	dodgeBasic,
	dodgeGround, dodgeAir,


	# Hit states
	hitBasic,
	hitGround, hitAir, downedGround, downedAir, downedLanding,

	# u ded lmao skill issue
	death,


	# Combat can cancel out movement, but not eachother, but may be queried
	lightAttackBasic,
	heavyAttackBasic,
	
	# The sidearm type cannot be determined during polling time
	sidearm,
	ranged,
	whip,
	
	earthQuake,
	piercingShot,
	sonOfHeaven,

	# Taunts
	tauntBasic,
}


enum Priority {
	idle = 0,
	groundedMovementTypes = 1,
	interactionTypes = 10,
	fallingTypes = 20,
	jumpingTypes = 30,
	combatTypes = 40,
	evasionTypes = 50,
	damageTypes = 60,
	overwrite = 999,
}

#endregion


#region Exported variables

@export_group("General")
@export var TYPE : Type
@export var PRIORITY : int = 0
@export var ANIMATION_NAME : String
@export var ROTATION_TRACKING_SPEED : float = 10

@export_group("Combat")
@export var ENERGY_COST : float = 0
# @export var QUEUEABLE : bool = false # For what?

#endregion


#region Scene members

var player : Player
var manager : PlayerActionManager
var combatManager : PlayerCombatManager
var actionData : PlayerActionData
var resources : PlayerResources
var animationPlayer : AnimationPlayer

#endregion


#region Member variables

var _progress : float
var DURATION : float

var _queue : Type = Type.none # Queued action, used for combos and buffering, not guaranteed to happen next
var _next : Type = Type.none # Guaranteed next action after the current one has ended

#endregion


#region Public funcitons

func init(
	player_ : Player,
	manager_ : PlayerActionManager,
	combatManager_ : PlayerCombatManager,
	actionData_ : PlayerActionData,
	resources_ : PlayerResources,
	animationPlayer_ : AnimationPlayer,
) -> void:
	player = player_
	manager = manager_
	combatManager = combatManager_
	actionData = actionData_
	resources = resources_
	animationPlayer = animationPlayer_


# This is executed on action enter
func enter() -> void:
	resources.payAction(self)
	
	# if combatManager.isNextComboAction(TYPE):
	#	ANIMATION_NAME = combatManager.registerComboAction(TYPE)

	animationPlayer.play(ANIMATION_NAME)
	
	enterImpl()

# This is executed on action exit and resets the action to prepare it for the next time it's activated
func exit() -> void:
	exitImpl()
	
	_progress = 0
	
	_queue = Type.none
	_next = Type.none


# This is called on every frame when the action is enabled
func tick(input : PlayerInputManager.Data, delta : float) -> void:
	_progress += delta

	if actionData.trackDirection(ANIMATION_NAME, _progress):
		_processDirection(input, delta)
	
	tickImpl(input, delta)

	# if actionData.rootMotionEnabled(ANIMATION_NAME, _progress):
	#	_processRootMotion(delta)


# This checks if the current action should continue or if not, the action to transition to based on all inputs
func nextAction(input : PlayerInputManager.Data) -> Type:
	if actionData.acceptsQueue(ANIMATION_NAME, _progress) and input.actions.size() == 0: # Set the queued action
		_checkAndSetQueue(input)

	if not actionData.transitionable(ANIMATION_NAME, _progress):
		return Type.none
	
	# From this point on, we can freely transition to anything we want

	if _queue != Type.none: # If a transition can occur and the queue is set, push the queue as the next action
		_checkAndSetNext(_queue)

	if _next == Type.none: # If all above cases do not trigger a transition, just check for the input causing the highest priority action
		_next = _highestPriorityAction(input)
	
	# After the most likely input-based action has been decided, other factors like physics may be taken into account
	_next = nextStateImpl(_next)

	return _next


# Explicit definition of higher priority

static func hasHigherPriority(first : PlayerAction, second : PlayerAction) -> bool:
	return first.PRIORITY > second.PRIORITY

func hasHigherPriorityThan(second : Type) -> bool:
	return PRIORITY > manager.actions[second].PRIORITY


#endregion


#region Private functions

# Check if a queueable move is present, can be queued with the current action and set it if these are the case
func _checkAndSetQueue(input : PlayerInputManager.Data) -> void:
	_queue = input.actions[0]

	# Checks if a pause has been detected and a pause is part of the combo
	if actionData.comboPause(ANIMATION_NAME, _progress):
		if combatManager.isNextComboAction(Type.idle):
			combatManager.registerComboAction(Type.idle) # Add the pause to the combo
		# else: # This can be uncommented and the function below implemented to add punishment for button mashing
		#	combatManager.breakCombo()


# Check if the next action can be set (i.e. has a higher priority than the current next action)
func _checkAndSetNext(actionType : Type) -> void:
	if _next == Type.none: # If it were none, just set the action type
		_next = actionType

	var action := manager.actions[actionType]
	if resources.canAffordAction(action) and hasHigherPriority(manager.actions[_next], action): # Check for the priorities of the potential next actions
		_next = actionType


# Gets the highest priority action from the current input, given it has a higher pritority than the current one
func _highestPriorityAction(input : PlayerInputManager.Data) -> Type:
	# Go through all higher priority actions and immediately return them if possible as they can cancel the current action
	for actionType in input.actions:
		var action := manager.actions[actionType]

		# If both animations have the same type, just ignore it and break
		if action.TYPE == TYPE:
			break # We can directly break instead of continuing, since the actions are sorted by priority
		
		if resources.canAffordAction(action):
			return actionType
	
	return Type.none


# If enabled, this will influence the direction the player faces using the direction of the input package
func _processDirection(input : PlayerInputManager.Data, delta : float) -> void:
	player.rotate_y(clampf( \
		player.basis.z.signed_angle_to(Vector3(input.direction.x, 0, input.direction.y), Vector3.UP), \
		-ROTATION_TRACKING_SPEED * delta, ROTATION_TRACKING_SPEED * delta))


# If enabled, this will add root motion to the animation
func _processRootMotion(delta : float) -> void:
	player.set_quaternion(player.get_quaternion() * animationPlayer.get_root_motion_rotation())
	player.velocity += (
		animationPlayer.get_root_motion_rotation_accumulator().inverse() * 
		player.get_quaternion()
	) * animationPlayer.get_root_motion_position() / delta

#endregion


#region Implementation functions

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass

func tickImpl(_input : PlayerInputManager.Data, _delta : float) -> void:
	pass

func nextStateImpl(next : Type):
	return next

#endregion
