extends Node
class_name EntityResources


#region Exported variables

@export_group("Resources")
@export var health : ValueResource = null
@export var energy : ValueResource = null
@export var superArmor : ValueResource = null

#endregion


#region Scene members

@export_group("Scene members")
@export var actionManager : EntityActionManager

#endregion


#region Built-in functions

func _ready() -> void:
	assert(actionManager != null, "EntityResources._ready(): Entity action manager not assigned!")

#endregion


#region Public functions

func takeDamage(hitData : HitboxData) -> void:
	if not actionManager.currentState.vulnerable():
		return

	superArmor.value -= hitData.SUPER_ARMOR_DAMAGE
	health.value -= hitData.DAMAGE

	if not health.locked:
		actionManager.interrupt(EntityAction.Type.damage)
		_implTakeDamage(hitData)


func payable(action : EntityAction) -> bool:
	return action.ENERGY_COST <= energy.value and _implPayable(action)

func pay(action : EntityAction) -> void:
	energy.value -= action.ENERGY_COST

	_implPay(action)

#endregion


#region Implementation functions

@warning_ignore("unused_parameter")
func _implTakeDamage(hitData : HitboxData) -> void:
	pass


@warning_ignore("unused_parameter")
func _implPayable(action : EntityAction) -> bool:
	return true

@warning_ignore("unused_parameter")
func _implPay(action : EntityAction) -> void:
	pass

#endregion
