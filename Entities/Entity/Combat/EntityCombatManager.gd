extends Node
class_name EntityCombatManager


#region Member variables

@onready var _comboTree : EntityComboAction = EntityComboAction.new(null)
@onready var _currentComboAction : EntityComboAction = _comboTree

#endregion


#region Public functions

# Unlock a combo by getting a combo array and pushing it into the combo tree
func unlockCombo(combo : EntityCombo) -> void:
	var count := combo.ACTIONS.size()
	assert(combo.ACTION_TYPES.size() == combo.ACTIONS.size(), "EntityCombatManager.unockCombo(): Invalid combo! Make sure that there are the same amount of actions and their types.")

	var action := _comboTree
	for i : int in range(count):
		var type := combo.ACTION_TYPES[i]

		action = action.tree.get_or_add(type, EntityComboAction.new(combo.ACTIONS[i])) if not action.tree.has(type) else action.tree.get(type)

	action.COMBO_TYPE = combo.TYPE


func resetActiveCombo() -> void:
	if _currentComboAction.COMBO_TYPE != StringName(): # Only true if this was last action in combo
		_resetFinishedCombo(_currentComboAction)

	_currentComboAction = _comboTree

func hasActiveCombo() -> bool:
	return _currentComboAction.DATA != null

func isNextComboAction(action : StringName) -> bool:
	return _currentComboAction.tree.has(action)

func validComboActions() -> Array[StringName]:
	return _currentComboAction.tree.keys()


# Registers the next action in a combo chain and returns the data of the current action. If the action is not part of a combo, returns null
func registerComboAction(action : StringName) -> EntityActionData:
	if !isNextComboAction(action):
		return null
	
	_currentComboAction = _currentComboAction.tree[action]
	
	return _currentComboAction.DATA

#endregion


#region Implementation functions

@warning_ignore("unused_parameter")
func _resetFinishedCombo(action : EntityComboAction) -> void:
	pass

#endregion
