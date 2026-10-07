extends AnimationTree
class_name EntityAnimator


#region Helper structures

class DriverType:
	const transition := &"Transition"
	const animation := &"Animation"
	const blendLine := &"BlendSpace1D"
	const blendSpace := &"BlendSpace2D"
	const addition := &"Add2"
	const blend := &"Blend2"
	const blend3 := &"Blend3"
	const addition3 := &"Add3"
	const subtraction := &"Sub2"


class TransitionDriverActivity extends Resource:
	var slot : int = 0

	var first : StringName
	var second : StringName

	func _init(driver : StringName, type : StringName) -> void:
		first = driver + type + str(1)
		second = driver + type + str(2)


class ScaledAnimation extends Resource:
	var anim : StringName
	var scale : StringName

	func _init(driver : StringName, idx : int) -> void:
		var idxStr := str(idx)
		anim = driver + &"Anim" + idxStr
		scale = driver + &"Scale" + idxStr

class AutoBlendDriver extends Resource:
	var first : ScaledAnimation
	var second : ScaledAnimation

	func _init(driver : StringName) -> void:
		first = ScaledAnimation.new(driver, 1)
		second = ScaledAnimation.new(driver, 2)

#endregion


#region Constants

# Parameter names

const PARAMETER_ADD := &"add_amount"
const PARAMETER_SUB := &"sub_amount"
const PARAMETER_BLEND := &"blend_amount"
const PARAMETER_BLEND_POS := &"blend_position"
const PARAMETER_SCALE := &"scale"
const PARAMETER_TRANSITION_REQUEST := &"transition_request"
const PARAMETER_CURRENT_STATE := &"current_state"

#endregion


#region Exported variables

@export var DEFAULT_ANIMATION_NAME : StringName = &""
@export var COPY_ANIMATION_TREE_ON_INSTANTIATON : bool = false

#endregion


#region Member variables

# References

@onready var _defaultAnimation : Animation = get_animation(DEFAULT_ANIMATION_NAME)


# State

var _transitionDriverActivity : Dictionary[StringName, TransitionDriverActivity] = { }
var _autoBlendDrivers : Dictionary[StringName, AutoBlendDriver] = { }


# Root motion

@export var rootOrientation : Quaternion = Quaternion.IDENTITY

#endregion


#region Built-in functions

func _ready() -> void:
	assert(_defaultAnimation != null, "EntityAnimator._ready(): Default animation not found!")

	if COPY_ANIMATION_TREE_ON_INSTANTIATON:
		tree_root = tree_root.duplicate_deep()

	_initialize()

#endregion


#region Public functions

# Transitions

func registerAutoTransition(handle : StringName, type : StringName) -> void:
	var activity := TransitionDriverActivity.new(handle, type)
	_transitionDriverActivity[handle] = activity

func registerAutoBlendDriver(handle : StringName) -> void:
	var data := AutoBlendDriver.new(handle)
	_autoBlendDrivers[handle] = data


# Transition to an unused driver in a transition driver registered with registerAutoTransition()
func transitionToUnused(transitionHandle : StringName, driverHint : AnimationNodeTransition = null) -> void:
	var activity := _transitionDriverActivity.get(transitionHandle) as TransitionDriverActivity
	assert(activity != null, "EntityAnimator.transitionToUnused(): This function is only available to nodes which have been registered with registerAutoTransition()!")
	activity.slot += (1 if activity.slot == 0 else -1)

	set(
		parameterName(transitionHandle, &"transition_request"), 
		(transitionDriver(transitionHandle) if driverHint == null else driverHint).get_input_name(activity.slot)
	)

# Transition to a driver
func transitionTo(handle : StringName, slot : String) -> bool:
	if transitionCurrent(handle) == slot:
		return false

	set(parameterName(handle, PARAMETER_TRANSITION_REQUEST), slot)
	return true


# Set the transition driver which the core transition driver points to
func setCoreTransition(destTransitionHandle : StringName, fadeTime : float) -> AnimationNodeTransition:
	var destTransitionDriver := transitionDriver(destTransitionHandle)
	destTransitionDriver.xfade_time = 0.0

	transitionDriver(&"CoreTransition").xfade_time = fadeTime

	# IMPORTANT: Guarantee that the destination transition handle is always named the same as the input
	if not transitionTo(&"CoreTransition", destTransitionHandle):
		destTransitionDriver.xfade_time = fadeTime # If we were already on the correct path, we transition using the inner transitioner instead
	
	return destTransitionDriver


# Driver getters

func transitionDriver(handle : StringName) -> AnimationNodeTransition:
	return tree_root.get_node(handle) as AnimationNodeTransition

func animationDriver(handle : StringName) -> AnimationNodeAnimation:
	return tree_root.get_node(handle) as AnimationNodeAnimation

func additionDriver(handle : StringName) -> AnimationNodeAdd2:
	return tree_root.get_node(handle) as AnimationNodeAdd2

func addition3Driver(handle : StringName) -> AnimationNodeAdd3:
	return tree_root.get_node(handle) as AnimationNodeAdd3

func subtractionDriver(handle : StringName) -> AnimationNodeSub2:
	return tree_root.get_node(handle) as AnimationNodeSub2

func blendDriver(handle : StringName) -> AnimationNodeBlend2:
	return tree_root.get_node(handle) as AnimationNodeBlend2

func blend3Driver(handle : StringName) -> AnimationNodeBlend3:
	return tree_root.get_node(handle) as AnimationNodeBlend3

func blendLineDriver(handle : StringName) -> AnimationNodeBlendSpace1D:
	return tree_root.get_node(handle) as AnimationNodeBlendSpace1D

func blendSpaceDriver(handle : StringName) -> AnimationNodeBlendSpace2D:
	return tree_root.get_node(handle) as AnimationNodeBlendSpace2D


func autoBlendDriver(handle : StringName) -> AutoBlendDriver:
	return _autoBlendDrivers.get(handle) as AutoBlendDriver


# Get handle for an unused driver in a transition driver registered with registerAutoTransition()
func unusedHandle(transitionHandle : StringName) -> StringName:
	var activity := _transitionDriverActivity.get(transitionHandle) as TransitionDriverActivity
	assert(activity != null, "EntityAnimator.unusedHandle(): This function is only available to nodes which have been registered with registerAutoTransition()!")

	if activity.slot == 0:
		return activity.second
	return activity.first


# Driver configuration

func setAdditionAmount(handle : StringName, pos : float) -> void:
	set(parameterName(handle, PARAMETER_ADD), pos)

func setSubtractionAmount(handle : StringName, pos : float) -> void:
	set(parameterName(handle, PARAMETER_SUB), pos)

func setBlendAmount(handle : StringName, pos : float) -> void:
	set(parameterName(handle, PARAMETER_BLEND), pos)

func setBlendPosition(handle : StringName, pos : float) -> void:
	set(parameterName(handle, PARAMETER_BLEND_POS), pos)

func setScale(handle : StringName, amount : float) -> void:
	set(parameterName(handle, PARAMETER_SCALE), amount)


func transitionCurrent(handle : StringName) -> StringName:
	return get(parameterName(handle, PARAMETER_CURRENT_STATE))


# Parameter names

func parameterName(driverName : StringName, paramName : StringName) -> StringName:
	return "parameters/" + driverName + "/" + paramName


# Safe animation retrieval

func animation(animName : StringName) -> Animation:
	var anim := get_animation(animName)

	if anim == null:
		push_error("EntityAnimator.animation(): Animation not found! Returning default animation.")
		return _defaultAnimation

	return anim

#endregion


#region Private functions

func _getDriver(driverName : StringName) -> AnimationNode:
	return tree_root.get_node(driverName)

#endregion


#region Implementation functions

func _initialize() -> void:
	pass

func reset() -> void:
	pass

#endregion
