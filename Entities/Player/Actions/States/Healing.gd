extends PlayerBasicStopAction
class_name PlayerHealing


#region Exported variables

@export_group("Healing settings")
@export var HEAL_VALUE : float = 10.0
@export var ENERGY_PER_HEAL : float = 5.0
@export var ENERGY_CONSUMPTION_RATE : float = 10.0

#endregion


#region Member variables

var _energyConsumed : float = 0.0

#endregion


#region Override functions

func _implExit() -> void:
	_energyConsumed = 0.0 # Evil punishment


func _implTick(delta : float) -> void:
	super._implTick(delta)

	var health := resources().health
	var energy := resources().energy

	if (health.locked
		or energy.locked
		or health.value >= health.maxValue
		or energy.value <= 0.0
	):
		return

	var currentEnergy := energy.value
	energy.value -= ENERGY_CONSUMPTION_RATE * delta

	_energyConsumed += currentEnergy - energy.value

	if _energyConsumed >= ENERGY_PER_HEAL:
		health.value += HEAL_VALUE

		_energyConsumed -= ENERGY_PER_HEAL


func _implNextAction(next : StringName) -> StringName:
	if not inputs().modifiers.has(PlayerAction.Type.heal) and next != Type.none: # Anything should interrupt healing if we're not pressing anymore
		return next

	return Type.none

#endregion
