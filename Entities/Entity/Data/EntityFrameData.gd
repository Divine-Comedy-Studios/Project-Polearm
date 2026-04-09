@warning_ignore_start("unused_private_class_variable")

extends AnimationPlayer
class_name EntityFrameData


#region Exported action properties

@export_group("Animation")
@export var _transitionable : bool = true
@export var _rotationTracking : float = 0.0

@export_group("Behavior")
@export var _invincible : bool = false

#endregion


#region Public functions

func transitionable(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_transitionable", time) as bool

func rotationTracking(animationName : StringName, time : float) -> float:
	return _getValue(animationName, ^"FrameData:_rotationTracking", time) as float


func invincible(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_invincible", time) as bool

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
