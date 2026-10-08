extends NinjaSoliderAction

# Attack which chains into a combo using the combat manager: every time this state is entered it takes the data
# of the next hit of the combo (see SoliderAction._enter()), until the last hit has been done.
#
# Scene setup: TYPE = Type.lightAttack, PRIORITY = Priority.combatTypes (40) or higher, REPEATABLE = true,
# COMBO = a combo with the action type lightAttack for each of its hits, and the data of each hit as its actions.
# Frame data: _nonLowerable = true until the recovery, _transitionable = true from where the next hit may start,
# and a short _rotationTracking at the start of each hit so the solider aims at the player.


#region Exported variables

@export_group("Combo settings")
@export var COMBO : EntityCombo = null

#endregion


#region Member variables

var _lastHit : bool = false
var _chained : bool = false # The next hit follows
var _completed : bool = false # The last hit was played to its end

#endregion


#region Override functions

func _implInit() -> void:
	assert(COMBO != null, "ComboAttack._implInit(): Combo not assigned!")
	assert(combatManager() != null, "ComboAttack._implInit(): The action manager needs a combat manager!")

	combatManager().unlockCombo(COMBO)


func _implEnter() -> void:
	# The combat manager has been reset when it handed out the last hit
	_lastHit = not combatManager().hasActiveCombo()
	_chained = false
	_completed = false

	controller().beforeComboHit(_lastHit)

	_animationSetupBasic()

func _implExit() -> void:
	controller().afterComboHit(_chained, _completed)

	weapon().disable()


func _implTick(_delta : float) -> void:
	if not entity().onGround():
		rootMotionEnabled = false

	if _lastHit and finished():
		_completed = true


func _implNextAction(next : StringName) -> StringName:
	# The next hit of the combo takes priority over everything else, all of the hits are done in a row
	if not _lastHit and controller().comboChaining:
		_chained = true

		return TYPE

	return next

#endregion
