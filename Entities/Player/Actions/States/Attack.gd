extends PlayerAction
class_name PlayerAttack


#region Member variables

var _addedEnergy : bool = false

#endregion


#region Override functions

func _implEnter() -> void:
	_animationSetupBasic()

	_addedEnergy = false


func _implTick(_delta : float) -> void:
	if weapon().hitCount > 0 and not _addedEnergy:
		resources().energy.value += data.ENERGY_GAIN

		_addedEnergy = true

#endregion
