extends PlayerBasicStopAction
class_name PlayerHealing


#region Exported variables

@export_group("Healing settings")
@export var HEAL_VALUE : float = 10.0
@export var ENERGY_PER_HEAL : float = 5.0
@export var ENERGY_CONSUMPTION_RATE : float = 10.0
@export var HEAL_PAUSE_TIME : float = 1.0

#endregion


#region Member variables

var _pauseTimer : float = 0.0
var _energyConsumed : float = 0.0

var _stopHealing : bool = false

#endregion


#region Override functions

func _implEnter() -> void:
	Globals.sfxManager.play(SFXData.Type.heal, player().global_position)

func _implExit() -> void:
	_energyConsumed = 0.0 # Evil punishment
	_pauseTimer = 0.0

	_stopHealing = false


func _implTick(delta : float) -> void:
	super._implTick(delta)

	if _pauseTimer >= 0.0: # Wait a bit between heals
		_pauseTimer -= delta

		return

	var health := resources().health
	var energy := resources().energy

	if (health.locked
		or energy.locked
		or health.value >= health.maxValue
		or energy.value <= 0.0
	):
		_stopHealing = true

		return

	var currentEnergy := energy.value
	energy.value -= ENERGY_CONSUMPTION_RATE * delta

	_energyConsumed += currentEnergy - energy.value

	if _energyConsumed >= ENERGY_PER_HEAL:
		Globals.sfxManager.play(SFXData.Type.heal, player().global_position)

		_energyConsumed -= ENERGY_PER_HEAL # Could set this to 0, but this is a bit more forgiving
		health.value += HEAL_VALUE

		_pauseTimer = HEAL_PAUSE_TIME


func _implNextAction(next : StringName) -> StringName:
	if next != Type.none: # Healing should only be interrupted when it realllly needs to be, for some punishing aspects
		if ((not inputs().modifiers.has(PlayerAction.Type.heal)
			and _pauseTimer > 0.0	
			and hasHigherPriorityThan(next))
			or _stopHealing # This flag forces healing to stop
		):
			return next

	return Type.none

#endregion
