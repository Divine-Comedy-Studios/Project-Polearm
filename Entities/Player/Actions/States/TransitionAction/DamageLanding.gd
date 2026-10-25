extends PlayerBasicStopAction


#region Member variables

var _dead : bool = false

#endregion


#region Override functions

func _implEnter() -> void:
	if resources().health.value <= 0.0:
		_dead = true

		player().detachGround()
		resources().health.locked = true

	_animationSetupBasic()

func _implExit() -> void:
	_dead = false


func _implTick(delta : float) -> void:
	super._implTick(delta)

	if finished() and _dead:
		Globals.world.gameOver()


func _implNextAction(_next : StringName) -> StringName:
	return Type.damageStandUp if not _dead else Type.none

#endregion
