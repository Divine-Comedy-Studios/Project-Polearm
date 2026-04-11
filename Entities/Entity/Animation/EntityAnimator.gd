extends AnimationTree
class_name EntityAnimator


#region Helper structures

class DriverType:
	const transition := &"Transition"
	const animation := &"Animation"
	const blendLine := &"BlendSpace1D"
	const blendSpace := &"BlendSpace2D"
	const addition := &"Add2"
	const addition3 := &"Add3"
	const subtraction := &"Sub2"


class TransitionDriverActivity extends Resource:
	var name : StringName = StringName()
	var slot : int = 0

#endregion


#region Constants

# Parameter names

const PARAMETER_BLEND_POS := &"blend_position"
const PARAMETER_ADD := &"add_amount"
const PARAMETER_SUB := &"sub_amount"

#endregion


#region Exported variables

@export var DEFAULT_ANIMATION_NAME : StringName = &""

#endregion


#region Member variables

# References

@onready var _animationPlayer : AnimationPlayer = get_node(anim_player)
@onready var _defaultAnimation : Animation = get_animation(DEFAULT_ANIMATION_NAME)


# Animation blend tree reference

var _transitionDriverActivity : Dictionary[StringName, TransitionDriverActivity] = { }


# Root motion

@export var rootOrientation : Quaternion = Quaternion.IDENTITY

#endregion


#region Built-in functions

func init() -> void:
	assert(_animationPlayer != null, "EntityAnimator._ready(): Animation player not found!")
	assert(_defaultAnimation != null, "EntityAnimator._ready(): Default animation not found!")

	_playInitialAnimation()

#endregion


#region Public functions

func transitionTo(transHandle : StringName, handle : StringName) -> void:
	var activity := _transitionDriverActivity.get(transHandle) as TransitionDriverActivity
	if activity == null:
		_transitionDriverActivity[transHandle] = TransitionDriverActivity.new()
		activity = _transitionDriverActivity.get(transHandle) as TransitionDriverActivity
	
	activity.slot += (1 if activity.slot == 0 else -1)
	activity.name = handle

	tree_root.disconnect_node(transHandle, activity.slot)
	tree_root.connect_node(transHandle, activity.slot, handle)
	set(parameterName(transHandle, &"transition_request"), transitionDriver(transHandle).get_input_name(activity.slot))


# Driver functions

func transitionDriver(handle : StringName) -> AnimationNodeTransition:
	return tree_root.get_node(handle) as AnimationNodeTransition

func animationDriver(handle : StringName) -> AnimationNodeAnimation:
	return tree_root.get_node(handle) as AnimationNodeAnimation

func additionDriver(handle: StringName) -> AnimationNodeAdd2:
	return tree_root.get_node(handle) as AnimationNodeAdd2

func addition3Driver(handle: StringName) -> AnimationNodeAdd3:
	return tree_root.get_node(handle) as AnimationNodeAdd3

func subtractionDriver(handle: StringName) -> AnimationNodeSub2:
	return tree_root.get_node(handle) as AnimationNodeSub2

func blendLineDriver(handle : StringName) -> AnimationNodeBlendSpace1D:
	return tree_root.get_node(handle) as AnimationNodeBlendSpace1D

func blendSpaceDriver(handle : StringName) -> AnimationNodeBlendSpace2D:
	return tree_root.get_node(handle) as AnimationNodeBlendSpace2D


# Driver names

func transitionHandle(index : int = 0, parent : StringName = StringName()) -> StringName: # Transition nodes are usually at the core of a animation tree and manually picked
	return _driverHandle(index, DriverType.transition, parent)

func animationHandle(index : int = -1, parent : StringName = StringName()) -> StringName:
	return _driverHandle(index, DriverType.animation, parent)

func additionHandle(index: int = -1, parent: StringName = StringName()) -> StringName:
	return _driverHandle(index, DriverType.addition, parent)

func addition3Handle(index: int = -1, parent: StringName = StringName()) -> StringName:
	return _driverHandle(index, DriverType.addition3, parent)

func subtractionHandle(index: int = -1, parent: StringName = StringName()) -> StringName:
	return _driverHandle(index, DriverType.subtraction, parent)

func blendLineName(index : int = -1, parent : StringName = StringName()) -> StringName:
	return _driverHandle(index, DriverType.blendLine, parent)

func blendSpaceName(index : int = -1, parent : StringName = StringName()) -> StringName:
	return _driverHandle(index, DriverType.blendSpace, parent)


# Driver configuration

func setAdditionAmount(driverName : StringName, pos : Vector3) -> void:
	set(parameterName(driverName, PARAMETER_ADD), pos)

func setAddition3Amount(driverName : StringName, pos : Vector3) -> void:
	set(parameterName(driverName, PARAMETER_ADD), pos)

func setSubtractionAmount(driverName : StringName, pos : Vector3) -> void:
	set(parameterName(driverName, PARAMETER_SUB), pos)

func setBlendLinePosition(driverName : StringName, pos : float) -> void:
	set(parameterName(driverName, PARAMETER_BLEND_POS), pos)

func setBlendSpacePosition(driverName : StringName, pos : Vector3) -> void:
	set(parameterName(driverName, PARAMETER_BLEND_POS), pos)


# Parameter names

func parameterName(driverName : StringName, paramName : StringName) -> StringName:
	return "parameters/" + driverName + "/" + paramName


# Get animation from animation player

func animation(animName : StringName) -> Animation:
	var anim := _animationPlayer.get_animation(animName)

	if anim == null:
		push_error("EntityAnimator.animation(): Animation not found! Returning default animation.")
		return _defaultAnimation

	return anim

#endregion


#region Private functions

func _getDriver(driverName : StringName) -> AnimationNode:
	return tree_root.get_node(driverName)


# Naming utility

func _driverHandle(index : int, driverType : StringName, parentName : StringName) -> StringName:
	var baseName := _baseDriverHandle(driverType, parentName)
	return baseName + _findIndexToString(index, baseName)


# Index utility

func _baseDriverHandle(driverType : StringName, parentName : StringName) -> StringName:
	if parentName.is_empty():
		return driverType
	return StringName(parentName + &"/") + driverType

func _findIndexToString(index : int, driverBase : StringName) -> StringName:
	if index >= 0:
		return _indexToString(index)

	index = 0
	var indexString := _indexToString(index)

	for activity : TransitionDriverActivity in _transitionDriverActivity.values():
		if activity.name == (driverBase + indexString):
			index += 1
			indexString = _indexToString(index)
	
	return indexString

func _indexToString(index : int) -> StringName:
	return StringName() if index == 0 else StringName(&" " + str(index + 1))

#endregion


#region Implementation functions

func _playInitialAnimation() -> void:
	pass

#endregion
