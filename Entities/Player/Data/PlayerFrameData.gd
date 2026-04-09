@warning_ignore_start("unused_private_class_variable")

extends EntityFrameData
class_name PlayerFrameData


#region Exported action properties

@export_group("Gameplay")
@export var _comboPause : bool = false
@export var _acceptsQueue : bool = false

#endregion


#region Public functions

func comboPause(animationName : String, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_comboPause", time)

func acceptsQueue(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_acceptsQueue", time) as bool

#endregion
