extends EntityAction
class_name PlayerAction


#region Enums

class Type:
	const none := EntityAction.Type.none
	

	# Idle
	const idle := EntityAction.Type.idle
	

	# Ground movement actions
	const walk := &"walk"
	const run := &"run"
	const sprint := &"sprin"
	

	# Jumping
	const jump := &"jump"

	const jumpStill := &"STjump"
	const jumpRun := &"RUjump"
	const jumpSprint := &"SPjump"

	# Falling
	const fall := &"fall"

	# The landing animation can always determined, hence it needs no intermediate action
	const landingStill := &"STland"
	const landingRun := &"RUland"
	

	# Dodge states
	const dodge := &"dodge"

	const dodgeGround := &"GRdodge"
	const dodgeAir := &"AIdodge"


	# Hit states
	const damage := EntityAction.Type.damage

	const hitGround := &"GRhit"
	const hitAir := &"AIhit"
	const downedGround := &"GRdown"
	const downedAir := &"AIdown"
	const downedLanding := &"LAdown"

	# u ded lmao skill issue
	const death := &"dead"


	# Combat can cancel out movement, but not eachother, but may be queried
	const lightAttack := &"LIattack"
	const heavyAttack := &"HEattack"
	
	# The sidearm type cannot be determined during polling time
	const sidearm := &"sidearm"
	const ranged := &"ranged"
	const whip := &"whip"
	
	const earthQuake := &"EQ"
	const piercingShot := &"PS"
	const sonOfHeaven := &"SOH"

	# Taunts
	const taunt := &""


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

@export_category("Behavior")
@export var QUEUEABLE : bool = false # Only some actions should be able to be put into a queue

@export_category("Combat")
@export var ENEMY_DETECTABLE : bool = false

#endregion


#region Member variables

var _queue : StringName = Type.none # Queued action, used for combos and buffering, not guaranteed to happen next

#endregion


#region Public funcitons

func player() -> Player:
	return context.entity as Player

func frameData() -> PlayerFrameData:
	return context.frameData as PlayerFrameData

func inputs() -> PlayerInputManager.Data:
	return context.inputManager.inputs

#endregion


#region Private functions

# Check if a queueable move is present, can be queued with the current action and set it if these are the case
func _checkAndSetQueue() -> void:
	if inputs().actions.size() == 0:
		return

	for actionType : StringName in inputs().actions:
		var action := context.action(actionType) as PlayerAction
		if not action.QUEUEABLE or actionViability(action) != 1:
			continue

		_queue = actionType
		_insertComboPause()

		return

# Checks if a pause has been detected and a pause is part of the combo
func _insertComboPause() -> void:
	if not context.frameData.comboPause(data.ANIMATION_NAME, _progress):
		return

	if context.combatManager.isNextComboAction(Type.idle):
		context.combatManager.registerComboAction(Type.idle) # Add the pause to the combo


# Gets the highest priority action from the current input, given it has a higher pritority than the current one
func _highestPriorityAction() -> StringName:
	var candidate := Type.none

	# Go through all higher priority actions and immediately return them if possible as they can cancel the current action
	for actionType : StringName in inputs().actions:
		var action := context.action(actionType) as PlayerAction
		var viability := actionViability(action)

		# These checks here occur due to a tiebreaker when there are multiple actions with the same priority
		if viability == 1:
			if action.PRIORITY != PRIORITY:
				return actionType if candidate == Type.none else candidate

			candidate = actionType
		elif viability == -1:
			return Type.none

	return candidate

#endregion


#region Override functions

func _enter() -> void:
	_implEnter()

func _exit() -> void:
	_queue = Type.none

	_implExit()


func _processActions() -> void:
	if frameData().acceptsQueue(data.ANIMATION_NAME, _progress): # Set the queued action
		_checkAndSetQueue()

func _nextAction() -> StringName:
	# If a transition can occur and the queue is set, push the queue as the next action, else just take the best action in the inputs
	return _implNextAction(_queue if _queue != Type.none else _highestPriorityAction())


func _processDirectionAngle() -> float:
	return player().basis.z.signed_angle_to(
		Vector3(inputs().direction.x, 0, inputs().direction.y), 
		Vector3.UP
	)

#endregion


#region Implementation functions

func _implEnter() -> void:
	pass

func _implExit() -> void:
	pass


func _implNextAction(next : StringName) -> StringName:
	return next

#endregion
