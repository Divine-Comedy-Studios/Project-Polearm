extends Node
class_name EntityResources


#region Exported variables

@export_group("Resources")
@export var health : ValueResource = null
@export var energy : ValueResource = null
@export var superArmor : ValueResource = null

@export_group("Super armor config")
@export var SUPER_ARMOR_RECOVERY_WAIT_TIME : float = 1.0
@export var SUPER_ARMOR_RECOVERY_RATE : float = 10.0

#endregion


#region Scene members

@export_group("Scene members")
@export var actionManager : EntityActionManager

#endregion


#region Member variables

var _superArmorWaitTime : float = 0.0

#endregion


#region Built-in functions

func _ready() -> void:
	assert(actionManager != null, "EntityResources._ready(): Entity action manager not assigned!")


func _physics_process(delta : float) -> void:
	if _superArmorWaitTime > 0.0:
		_superArmorWaitTime = clampf(_superArmorWaitTime - delta, 0.0, SUPER_ARMOR_RECOVERY_WAIT_TIME)
	else:
		superArmor.value += SUPER_ARMOR_RECOVERY_RATE * delta

#endregion


#region Public functions

func takeDamage(hitData : HitboxData) -> void:
	if not actionManager.vulnerable() or health.locked:
		return

	_superArmorWaitTime = SUPER_ARMOR_RECOVERY_RATE

	superArmor.value -= hitData.SUPER_ARMOR_DAMAGE
	health.value -= hitData.DAMAGE

	actionManager.interrupt(EntityAction.Type.damage)
	actionManager.payload = hitData

	_takeDamage(hitData)


func payable(action : EntityAction) -> bool:
	return action.ENERGY_COST <= energy.value and _payable(action)

func pay(action : EntityAction) -> void:
	energy.value -= action.ENERGY_COST

	_pay(action)


func reset() -> void:
	health.reset_state()
	energy.reset_state()
	superArmor.reset_state()

	_superArmorWaitTime = 0.0

	_reset()

#endregion


#region Implementation functions

@warning_ignore("unused_parameter")
func _takeDamage(hitData : HitboxData) -> void:
	pass


@warning_ignore("unused_parameter")
func _payable(action : EntityAction) -> bool:
	return true

@warning_ignore("unused_parameter")
func _pay(action : EntityAction) -> void:
	pass


func _reset() -> void:
	pass

#endregion
