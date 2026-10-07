@warning_ignore_start("unused_private_class_variable")

extends AnimationPlayer
class_name EntityFrameData


#region Exported action properties

@export_group("Animation")
@export var _transitionable : bool = true # Can the current action transition to another one?
@export var _nonLowerable : bool = false # Can this action not transition to a lower priority state?

@export_group("Behavior")
@export var _rotationTracking : float = 0.0 # Speed of rotation tracking
@export var _weaponActivate : bool = false # Is the weapon active

@export_group("Optional")
@export var _optional : bool = false # Optional flag that any state may decide to set or not

@export_group("Auto-Generated")
@export var _finished : bool = false # Automatically generated at the end of each track

#endregion


#region Public functions

func transitionable(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_transitionable", time) as bool

func nonLowerable(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_nonLowerable", time) as bool

func weaponActivate(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_weaponActivate", time) as bool

func finished(animationName : StringName, time : float) -> float:
	return _getValue(animationName, ^"FrameData:_finished", time) as bool

func optional(animationName : StringName, time : float) -> bool:
	return _getValue(animationName, ^"FrameData:_optional", time) as bool


func rotationTracking(animationName : StringName, time : float) -> float:
	return _getValue(animationName, ^"FrameData:_rotationTracking", time) as float

#endregion


#region Private functions

func _getValue(animationName : StringName, propertyName : NodePath, time : float) -> Variant:
	assert(name == &"FrameData", "EntityFrameData._getValue(): The node needs to be called \"FrameData\" in the editor!")
	assert(get_animation_library(&"FrameData") != null, "EntityFrameData._getValue(): Please make sure all animations are in the \"Data\" animation library!")

	var anim = get_animation("FrameData/" + animationName)
	if not anim:
		printerr("EntityFrameData._getValue(): Track has not been found! Returning null by default.")
		return 0

	return anim.value_track_interpolate(anim.find_track(propertyName, Animation.TrackType.TYPE_VALUE), time)

#endregion
