extends PlayerBasicStopAction


#region Override functions

func _implEnter() -> void:
	player().detachGround()
	hurtbox().disable()
	resources().health.locked = true

	_animationSetupBasic()


func _implTick(delta : float) -> void:
	super._implTick(delta) # Friction

	if finished():
		Globals.world.gameOver()

func _implNextAction(_next : StringName) -> StringName:
	return Type.none

#endregion
