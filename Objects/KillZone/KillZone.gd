extends Area3D
class_name KillZone

# Kills every entity whose hurtbox touches this area.
# Resize the child CollisionShape3D (or swap its shape) to change the zone, e.g. a wide flat box as a "plane".
# It ignores invulnerability and dodge frames, so there is no way to survive it.


#region Signals

signal killed(hurtbox : Hurtbox)

#endregion


#region Exported variables

## Which hurtbox layers count. Default: the Player layer (layer 2).
@export_flags_3d_physics var TARGET_LAYERS : int = 2:
	set(value):
		TARGET_LAYERS = value
		collision_mask = value

## Temporary: prints what happens, so you can see where the chain stops. Switch off once it works.
@export var DEBUG_PRINTS : bool = true

## Skip the death animation and go straight to the game over screen.
## Good for pits, where the player would otherwise hang in mid-air while dying.
@export var INSTANT_GAME_OVER : bool = false

#endregion


#region Member variables

var _reported : Dictionary = {}

#endregion


#region Built-in functions

func _ready() -> void:
	collision_layer = 0 # Nothing needs to detect the zone itself
	collision_mask = TARGET_LAYERS
	monitorable = false
	monitoring = true


func _physics_process(_delta : float) -> void:
	if Engine.is_editor_hint():
		return

	# Polling also catches a hurtbox that was switched off (dodge) while inside and comes back on.
	for area in get_overlapping_areas():
		if area is Hurtbox:
			_kill(area as Hurtbox)

#endregion


#region Private functions

func _kill(hurtbox : Hurtbox) -> void:
	if DEBUG_PRINTS and not _reported.has(hurtbox):
		_reported[hurtbox] = true
		print("[KILL] 1/4 KillZone touches hurtbox: ", hurtbox.get_path(), " (script: ", hurtbox.get_script().resource_path, ")")

	hurtbox.kill()
	killed.emit(hurtbox)

	if INSTANT_GAME_OVER:
		var globals := get_node_or_null("/root/Globals")
		if globals != null and globals.get("world") != null:
			globals.world.gameOver()

#endregion
