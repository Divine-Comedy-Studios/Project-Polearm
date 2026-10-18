@tool

extends Hitbox
class_name KillZone


#region Built-in functions

func _ready() -> void:
	super._ready()

	if not Engine.is_editor_hint():
		enable()

#endregion
