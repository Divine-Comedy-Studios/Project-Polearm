extends EntityAction
class_name DummyEnemyAction


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

	#endregion


	#region Aerial states

	# Falling
	const fall := &"fall"
	const ledgeGrab := &"ledgeGrab"

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

	# Damage determines its behavior on the fly
	const damage := EntityAction.Type.damage

	# u ded lmao skill issue
	const death := &"death"

	#endregion


	#region Constants

	const TO_AIR : Dictionary[StringName, StringName] = {
		Type.idle : Type.idle,
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
		Type.death : Type.death,
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


#region Override functions

func _enter() -> void:
	_implEnter()

func _exit() -> void:
	_implExit()


func _nextAction() -> StringName:
	return _implNextAction(_highestPriorityAction(intents().actions))


func _processDirectionAngle() -> float:
	var flatInput := Vector3(intents().direction.x, 0.0, intents().direction.y)
	if flatInput.is_zero_approx():
		return 0.0

	return entity().forward().signed_angle_to(
		flatInput, 
		Vector3.UP
	)

#endregion


#region Public funcitons

func entity() -> DummyEnemy:
	return _context.entity as DummyEnemy

func context() -> DummyEnemyActionManager:
	return _context as DummyEnemyActionManager

func intents() -> DummyEnemyController.Data:
	return _context.controller.intents

func frameData() -> DummyEnemyFrameData:
	return _context.frameData as DummyEnemyFrameData

func resources() -> DummyEnemyResources:
	return _context.resources as DummyEnemyResources

func animator() -> DummyEnemyAnimator:
	return _context.animator as DummyEnemyAnimator


func combatManager() -> EntityCombatManager:
	return _context.combatManager as  EntityCombatManager

#endregion


#region Private functions

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


func _implNextAction(next : StringName) -> StringName:
	return next

#endregion
