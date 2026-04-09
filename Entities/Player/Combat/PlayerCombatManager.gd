extends EntityCombatManager
class_name PlayerCombatManager


#region Enums

enum FlowState {
	none,
	mortal,
	cultivating,
	enlightened,
	sage,
	immortal,
	divine,
	heavenly,
}

#endregion


#region Exported variables

@export_group("Combat config")
@export var MAX_PREVIOUS_COMBO_COUNT : int

@export_group("Combat data")
@export var unlockedCombos : Array[EntityCombo]

#endregion


#region Scene members

@export_group("Scene members")
@export var resources : PlayerResources

#endregion


#region Member variables

var previousCombos : Array[StringName]

#endregion


#region Built-in functions

func _ready() -> void:
	assert(resources != null, "PlayerCombatManager._ready(): Resource container not assigned!")

	for combo in unlockedCombos:
		unlockCombo(combo)

#endregion


#region Public functions

# Returns how many combos ago the current combo was used
func comboPreviousUse(combo : StringName) -> int:
	for x in range(1, previousCombos.size() + 1):
		if previousCombos[-x] == combo:
			return x + 1

	return 0

#endregion


#region Override functions

func _resetFinishedCombo(action : EntityComboAction) -> void:
	if previousCombos.size() == MAX_PREVIOUS_COMBO_COUNT:
		previousCombos.pop_front()

	previousCombos.append(action.COMBO_TYPE)

#endregion
