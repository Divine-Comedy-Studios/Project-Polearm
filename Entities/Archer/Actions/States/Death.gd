extends ArcherAction


#region Override functions

func _implEnter() -> void:
	hurtbox().disable()
	resources().health.locked = true

	_animationSetupBasic()


func _implTick(delta : float) -> void:
	super._implTick(delta) # Friction

	if finished():
		context().kill()

func _implNextAction(_next : StringName) -> StringName:
	return Type.none

#endregion
