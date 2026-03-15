extends AnimationPlayer
class_name PlayerActionData


#region Exported action properties

@export_group("Animation")
@export var _transitionable : bool = true # originally false
# @export var interruptable : bool = true # I do not understand the purpose of why I added this, uncomment if it is useful and explain the difference between this and the option above
@export var _trackDirection : bool = false # If an action tracks the direction of the input, it also tracks the direction of the camera

@export_group("Movement")
@export var _rootMotion : bool = false
@export var _rootMotionPosition : Vector3 = Vector3.ZERO

@export_group("Combat")
@export var _vulnerable : bool = true
@export var _acceptsQueue : bool = false

# Certain combos in the game require the player to wait a small amount of time before before inputting the next move. This variable denotes
# from when on the combat manager will insert a pause into the combo upon pressing an input instead of just inserting the action normally
@export var _comboPause : bool = false


#endregion


#region Public functions

func transitionable(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_transitionable", time)

# func animInterruptable(animationName : String, time : float) -> bool:
#	return _getBooleanValue(animationName, "ActionData:interruptable", time)

func trackDirection(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_trackDirection", time)


func rootMotionEnabled(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_rootMotionEnabled", time)

func rootMotionPosition(animationName : String, time : float) -> Vector3:
	return _getVector3Value(animationName, "ActionData:_rootMotionPosition", time)


func vulnerable(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_vulnerable", time)

func comboPause(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_comboPause", time)

func acceptsQueue(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_acceptsQueue", time)

#endregion


#region Private functions

func _getBooleanValue(animationName : String, propertyName : String, time : float) -> bool:
	var anim = get_animation(animationName)
	return anim.value_track_interpolate(anim.find_track(propertyName, Animation.TrackType.TYPE_VALUE), time)

func _getVector3Value(animationName : String, propertyName : String, time : float) -> Vector3:
	var anim = get_animation(animationName)
	return anim.value_track_interpolate(anim.find_track(propertyName, Animation.TrackType.TYPE_VALUE), time)

#endregion
