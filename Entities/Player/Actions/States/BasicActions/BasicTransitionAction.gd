extends PlayerAction
class_name PlayerBasicTransitionAciton


#region Exported variables

@export var TARGET_TYPE : StringName = Type.none

#endregion


#region Override functions

func _implEnter() -> void:
	_setupBasicAnimation()


func _tick(_delta : float) -> void:
	if TARGET_TYPE != Type.none:
		context().pushActionQueue(TARGET_TYPE)

#endregion
