extends BasicEnemyAction
class_name SoliderAction


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
		Type.idle : Type.fall,
		Type.move : Type.fall,
		# Type.jumpStart : Type.airJumpStart,
		# Type.dashStart : Type.airDashStart,
		# Type.lightAttack : Type.airLightAttack,
		# Type.heavyAttack : Type.airHeavyAttack,

		Type.fall : Type.fall,
		# Type.ledgeGrab : Type.ledgeGrab,

		# The jump types are mapped onto themselves as the start animations handles this
		# Type.jump : Type.jump,
		# Type.airJump : Type.airJump,

		# Type.dash : Type.airDash,

		# Type.damage : Type.damage,
		Type.death : Type.death,
	}

	#endregion


enum Priority {
	idle = 0,
	groundedMovementTypes = 1,
	jumpingTypes = 30,
	combatTypes = 40,
	evasionTypes = 50,
	damageTypes = 60,
	overwrite = 999,
}

#endregion


#region Public funcitons

func entity() -> FloatingBody:
	return context().entity as FloatingBody

func context() -> SoliderActionManager:
	return _context as SoliderActionManager

func frameData() -> BasicEnemyFrameData:
	return context().frameData as BasicEnemyFrameData

func resources() -> BasicEnemyResources:
	return context().resources as BasicEnemyResources

func animator() -> SoliderAnimator:
	return context().animator as SoliderAnimator

func weapon() -> Hitbox:
	return context().weapon as Hitbox

#endregion


#region Private functions

# Convenient function to setup the animation for states which only use the basic animation
func _animationSetupBasic() -> void:
	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME
	animator().transitionToUnused(&"BasicTransition",
		animator().setCoreTransition(&"BasicTransition", data.ANIMATION_FADE_TIME))

#endregion
