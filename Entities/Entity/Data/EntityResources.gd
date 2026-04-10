@warning_ignore_start("unused_parameter")

extends Node
class_name EntityResources


#region Exported variables

@export_group("States")
@export var invincible : bool = false # Overrides the current invincibility of the state

@export_group("Properties")
@export var maxHealth : float = 100.0
@export var maxEnergy : float = 100.0
@export var maxSuperArmor : float = 100.0

#endregion


#region Scene members

@export_group("Scene members")
@export var actionManager : EntityActionManager

#endregion


#region Member variables

@onready var health : float = maxHealth:
	get:
		return health
	set(value):
		health = clampf(value, 0.0, maxHealth)

@onready var energy : float = maxEnergy:
	get:
		return energy
	set(value):
		energy = clampf(value, 0.0, maxEnergy)

@onready var superArmor : float = maxSuperArmor:
	get:
		return superArmor
	set(value):
		superArmor = clampf(value, 0.0, maxSuperArmor)

#endregion


#region Built-in functions

func _ready() -> void:
	assert(actionManager != null, "EntityResources._ready(): Entity action manager not assigned!")

#endregion


#region Public functions

func takeDamage(hitData : Hitbox.Data) -> void:
	if invincible:
		return
	if not actionManager.currentState.vulnerable():
		return

	if not actionManager.currentState.interruptable():
		superArmor -= hitData.superArmorDamage

	health -= hitData.damage

	actionManager.interrupt(EntityAction.Type.damage)

	_implTakeDamage(hitData)


func payable(action : EntityAction) -> bool:
	return action.ENERGY_COST <= energy and _implPayable(action)

func pay(action : EntityAction) -> void:
	energy -= action.ENERGY_COST

	_implPay(action)

#endregion


#region Implementation functions

func _implTakeDamage(hitData : Hitbox.Data) -> void:
	pass


func _implPayable(action : EntityAction) -> bool:
	return true

func _implPay(action : EntityAction) -> void:
	pass

#endregion
