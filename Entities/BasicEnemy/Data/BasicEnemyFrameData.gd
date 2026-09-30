@warning_ignore_start("unused_private_class_variable")

extends EntityFrameData
class_name BasicEnemyFrameData


#region Exported action properties

@export_group("Combat")
@export var _perfectDodge : bool = false

#endregion


#region Public functions

func perfectDodge(animationName : String, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_perfectDodge", time)

#endregion
