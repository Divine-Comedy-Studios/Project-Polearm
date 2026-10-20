@tool

extends Node3D
class_name Weapon


#region Enums

class Type:
	const debugWeapon := &"debug"

	const spear := &"spear"
	const arrow := &"arrow"
	const homing := &"homing"
	const scimitar := &"scimitar"

#endregion


#region Exported variables

@export var TYPE : StringName = Type.debugWeapon
@export var DEFAULT_HIT_DATA : HitboxData = null

#endregion


#region Scene members

@onready var hitbox : Hitbox = $Hitbox

#endregion


#region Built-in functions

func _ready() -> void:
	assert(DEFAULT_HIT_DATA != null, "Weapon._ready(): Default hit data not set!")

	hitbox.disable()

#endregion


#region Public functions

func enable(data : HitboxData = null) -> void:
	hitbox.enable(data if data != null else DEFAULT_HIT_DATA)

func disable() -> void:
	hitbox.disable()

func enabled() -> bool:
	return hitbox.enabled()

#endregion
