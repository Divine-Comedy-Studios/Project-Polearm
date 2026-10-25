@tool

extends Hitbox
class_name KillZone


func _ready() -> void:
	super._ready()

	if not Engine.is_editor_hint():
		enable()
