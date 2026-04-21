@warning_ignore_start("unused_private_class_variable")

extends AnimationPlayer
class_name EntityFrameData


#region Exported action properties

@export_group("Animation")
@export var _interruptable : bool = false # Can this action transition to an action of same or higher priority?
@export var _transitionable : bool = true # Can the current action transition to a lower priority one?
@export var _rotationTracking : float = 0.0 # Speed of rotation tracking

@export_group("Behavior")
@export var _vulnerable : bool = false # Is the entity vulnerable?

#endregion


#region Public functions

func transitionable(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_transitionable", time) as bool

func rotationTracking(animationName : StringName, time : float) -> float:
	return _getValue(animationName, ^"FrameData:_rotationTracking", time) as float


func vulnerable(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_vulnerable", time) as bool

func interruptable(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_interruptable", time) as bool

#endregion


#region Private functions

func _getValue(animationName : StringName, propertyName : NodePath, time : float) -> Variant:
	assert(name == &"FrameData", "EntityFrameData._getValue(): The node needs to be called \"ActionData\" in the editor!")
	assert(get_animation_library(&"FrameData") != null, "EntityFrameData._getValue(): Please make sure all animations are in the \"Data\" animation library!")

	var anim = get_animation("FrameData/" + animationName)
	if not anim:
		printerr("EntityFrameData._getValue(): Track has not been found! Returning null by default.")
		return 0

	return anim.value_track_interpolate(anim.find_track(propertyName, Animation.TrackType.TYPE_VALUE), time)

#endregion
