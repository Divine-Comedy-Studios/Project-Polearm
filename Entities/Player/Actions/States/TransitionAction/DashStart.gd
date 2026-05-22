extends PlayerBasicTransitionAciton


#region Scene members

@export_group("Scene members")
@export var _timer : Timer = null

#endregion


#region Override functions

func _implInit() -> void:
	assert(_timer != null, "Dash._implInit(): Assign dash timer!")


func _viable() -> bool:
	return _timer.is_stopped()

func _implExit() -> void:
	_timer.start()

#endregion
