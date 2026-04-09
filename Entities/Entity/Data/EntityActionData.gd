extends Resource
class_name EntityActionData


@export_category("Animation")
@export var ANIMATION_LIBRARY_NAME : StringName = StringName()
@export var ANIMATION_NAME : StringName = StringName()
@export var ROOT_MOTION = false

@export_category("Gameplay")
@export var HIT_DATA : Hitbox.Data = null


var ANIMATION_FULL_NAME : StringName:
	get:
		return StringName(ANIMATION_LIBRARY_NAME + &"/" + ANIMATION_NAME)
