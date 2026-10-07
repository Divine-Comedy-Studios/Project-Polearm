extends EntityAction
class_name PlayerAction


#region Enums

class Type:
	const none := EntityAction.Type.none


	#region Grounded states

	# Idle
	const idle := EntityAction.Type.idle
	

	# Ground movement actions
	const move := &"move"

	# Jumping
	const jumpStart := &"jumpStart"
	const jump := &"jump"

	# Dash states
	const dashStart := &"dashStart"
	const dash := &"dash"

	# Combat can cancel out movement, but not eachother, but may be queried
	const lightAttack := &"lightAttack"
	const heavyAttack := &"heavyAttack"

	# Death
	const death := &"death" # u ded lmao skill issue

	#endregion


	#region Pure grounded states

	# Landing
	const landing := &"landing"

	# Taunts
	const taunt := &""

	# Moving
	const moveStop := &"moveStop"
	const moveTurn := &"moveTurn"

	# Sprinting
	const sprint := &"sprint"
	const sprintStop := &"sprintStop"

	# Dashing
	const dashStop := &"dashStop"

	# Damage
	const damageLanding := &"damageLanding"
	const damageStandUp := &"damageStandUp"

	#endregion


	#region Aerial states

	# Falling
	const fall := &"fall"
	const ledgeGrab := &"ledgeGrab"

	# Damage
	const damageFall := &"damageFall"

	#endregion


	#region Grounded to aerial state
	# Aerial versions of grounded states, NEVER used by input manager

	const airJumpStart := &"airJumpStart"
	const airJump := &"airJump"

	const airDashStart := &"airDashStart"
	const airDash := &"airDash"

	const airLightAttack := &"airLightAttack"
	const airHeavyAttack := &"airHeavyAttack"

	#endregion


	#region Universal states

	const damage := EntityAction.Type.damage

	#endregion


	#region Constants

	const TO_AIR : Dictionary[StringName, StringName] = {
		Type.idle : Type.fall,
		Type.move : Type.fall,
		Type.jumpStart : Type.airJumpStart,
		Type.dashStart : Type.airDashStart,
		Type.lightAttack : Type.airLightAttack,
		Type.heavyAttack : Type.airHeavyAttack,

		Type.fall : Type.fall,
		Type.ledgeGrab : Type.ledgeGrab,

		# The jump types are mapped onto themselves as the start animations handles this
		Type.jump : Type.jump,
		Type.airJump : Type.airJump,

		Type.dash : Type.airDash,

		Type.damage : Type.damage,
	}

	#endregion

	# const earthQuake := &"EQ"
	# const piercingShot := &"PS"
	# const sonOfHeaven := &"SOH"


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

@export_group("Behavior")
@export var INPUT_BUFFER_FRAMES : int = 0
@export var QUEUEABLE : bool = false # Only some actions should be able to be put into a queue

@export_group("Combat")
@export var ENEMY_DETECTABLE : bool = false

#endregion


#region Member variables

var _queue : PlayerAction = null

#endregion


#region Override functions

func _enter() -> void:
	if _context.combatManager.isNextComboAction(TYPE):
		data = _context.combatManager.registerComboAction(TYPE)
	else:
		_context.combatManager.resetActiveCombo()

	_implEnter()

func _exit() -> void:
	_queue = null
	_implExit()


func _preprocessActions() -> void:
	if frameData().acceptsQueue(data.ANIMATION_NAME, _progress): # Set the queued action
		_checkAndSetQueue()

func _nextAction() -> StringName:
	# If a transition can occur and the queue is set, push the queue as the next action, else just take the best action in the inputs
	var queue := context().popActionQueue()
	return _implNextAction(queue
		if queue != Type.none and actionViability(context().action(queue)) == 1 else
			_highestPriorityAction(inputs().actions))

func _tick(delta : float) -> void:
	_processLedgeStopping()

	_implTick(delta)


func _processDirectionAngle() -> float:
	var flatInput := PPUtil.Math.flatToVec3(inputs().direction)
	if flatInput.is_zero_approx():
		return 0.0

	return player().forward().signed_angle_to(
		flatInput, 
		Vector3.UP
	)

#endregion


#region Public funcitons

func player() -> FloatingBody:
	return context().entity as FloatingBody

func context() -> PlayerActionManager:
	return _context as PlayerActionManager

func physics() -> PlayerPhysics:
	return context().physics as PlayerPhysics

func inputs() -> PlayerInputManager.Data:
	return context().inputManager.inputs

func frameData() -> PlayerFrameData:
	return context().frameData as PlayerFrameData

func resources() -> PlayerResources:
	return context().resources as PlayerResources

func animator() -> PlayerAnimator:
	return context().animator as PlayerAnimator

func weapon() -> Weapon:
	return context().weapon as Weapon

func combatManager() -> PlayerCombatManager:
	return context().combatManager as  PlayerCombatManager

func hurtbox() -> Hurtbox:
	return context().hurtbox

#endregion


#region Private functions

# Check if a queueable move is present, can be queued with the current action and set it if these are the case
func _checkAndSetQueue() -> void:
	if inputs().actions.size() == 0:
		return

	for actionType : StringName in inputs().actions:
		var action := context().action(actionType) as PlayerAction
		if not action.QUEUEABLE or actionViability(action, false) != 1:
			continue
		
		_queue = action
		_insertComboPause()

	if _queue != null:
		context().pushActionQueue(_queue.TYPE)

# Checks if a pause has been detected and a pause is part of the combo
func _insertComboPause() -> void:
	if not context().frameData.comboPause(data.ANIMATION_NAME, _progress):
		return

	if context().combatManager.isNextComboAction(Type.idle):
		context().combatManager.registerComboAction(Type.idle) # Add the pause to the combo


func _processLedgeStopping() -> void:
	if frameData().stopAtLedge(data.ANIMATION_NAME, _progress):
		if not context().ledgeStopper.enabled():
			context().ledgeStopper.enable()
	elif context().ledgeStopper.enabled():
		context().ledgeStopper.disable()


# Convenient function to setup the animation for states which only use the basic animation
func _animationSetupBasic() -> void:
	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME
	animator().transitionToUnused(&"BasicTransition", 
		animator().setCoreTransition(&"BasicTransition", data.ANIMATION_FADE_TIME))

#endregion


#region Implementation functions

func _implEnter() -> void:
	pass

func _implExit() -> void:
	pass

@warning_ignore("unused_parameter")
func _implTick(delta : float) -> void:
	pass


func _implNextAction(next : StringName) -> StringName:
	return next

#endregion
