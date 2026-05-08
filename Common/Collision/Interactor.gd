@tool

class_name Interactor
extends Area3D


#region Exported variables

@export_flags_3d_physics var layers : int:
	get:
		return collision_mask
	set(value):
		collision_mask = value

#endregion


#region Built-in functions

func _ready() -> void:
	if Engine.is_editor_hint():
		collision_layer = 0

		monitoring = true
		monitorable = false

#endregion


#region Public functions

func enable() -> void:
	monitoring = true

func disable() -> void:
	monitoring = false


func interact(payload : Variant = null) -> void:
	var interactables := get_overlapping_areas()
	var current : Interactable = null
	var currentDist : float = INF

	for interactable : Area3D in interactables:
		if interactable is Interactable:
			var dist := (interactable.global_position - global_position).length_squared()

			if current == null or currentDist > dist:
				currentDist = dist
				current = interactable as Interactable
	
	current.interact(payload)

#endregion
