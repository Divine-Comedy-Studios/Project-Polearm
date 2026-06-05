extends Resource
class_name EntityActionData


@export_group("Animation")
@export var ANIMATION_LIBRARY_NAME := StringName()
@export var ANIMATION_NAME := StringName()
@export var ROOT_MOTION : bool = false
@export var ANIMATION_FADE_TIME : float = 0.1

@export_group("Gameplay")
@export var HIT_DATA : Hitbox.Data = null


var ANIMATION_FULL_NAME : StringName:
	get:
		return StringName(ANIMATION_LIBRARY_NAME + &"/" + ANIMATION_NAME)
