extends AnimationTree
class_name EntityAnimationManager


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

func _ready() -> void:
	assert(_animationPlayer != null, "EntityAnimationManager._ready(): Animation player not found!")
	assert(_defaultAnimation != null, "EntityAnimationManager._ready(): Default animation not found!")

#endregion


#region Public functions

func transitionTo(transDriverName : StringName, driverName : StringName) -> void:
	var activity := _transitionDriverActivity.get(transDriverName) as TransitionDriverActivity
	if activity == null:
		_transitionDriverActivity[transDriverName] = TransitionDriverActivity.new()
		activity = _transitionDriverActivity.get(transDriverName) as TransitionDriverActivity
	
	activity.slot += (1 if activity.slot == 0 else -1)
	activity.name = driverName

	tree_root.disconnect_node(transDriverName, activity.slot)
	tree_root.connect_node(transDriverName, activity.slot, driverName)
	set(parameterName(transDriverName, &"transition_request"), transitionDriver(transDriverName).get_input_name(activity.slot))


# Driver functions

func transitionDriver(driverName : StringName) -> AnimationNodeTransition:
	return tree_root.get_node(driverName) as AnimationNodeTransition

func animationDriver(driverName : StringName) -> AnimationNodeAnimation:
	return tree_root.get_node(driverName) as AnimationNodeAnimation

func additionDriver(driverName: StringName) -> AnimationNodeAdd2:
	return tree_root.get_node(driverName) as AnimationNodeAdd2

func addition3Driver(driverName: StringName) -> AnimationNodeAdd3:
	return tree_root.get_node(driverName) as AnimationNodeAdd3

func subtractionDriver(driverName: StringName) -> AnimationNodeSub2:
	return tree_root.get_node(driverName) as AnimationNodeSub2

func blendLineDriver(driverName : StringName) -> AnimationNodeBlendSpace1D:
	return tree_root.get_node(driverName) as AnimationNodeBlendSpace1D

func blendSpaceDriver(driverName : StringName) -> AnimationNodeBlendSpace2D:
	return tree_root.get_node(driverName) as AnimationNodeBlendSpace2D


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


# Driver names

func transitionDriverName(index : int, parent : StringName = StringName()) -> StringName:
	return _parentToString(parent) + DriverType.transition + _indexToString(index)

func animationDriverName(index : int, parent : StringName = StringName()) -> StringName:
	return _parentToString(parent) + DriverType.animation + _indexToString(index)

func additionDriverName(index: int, parent: StringName = StringName()) -> StringName:
	return _parentToString(parent) + DriverType.addition + _indexToString(index)

func addition3DriverName(index: int, parent: StringName = StringName()) -> StringName:
	return _parentToString(parent) + DriverType.addition3 + _indexToString(index)

func subtractionDriverName(index: int, parent: StringName = StringName()) -> StringName:
	return _parentToString(parent) + DriverType.subtraction + _indexToString(index)

func blendLineDriverName(index : int, parent : StringName = StringName()) -> StringName:
	return _parentToString(parent) + DriverType.blendLine + _indexToString(index)

func blendSpaceDriverName(index : int, parent : StringName = StringName()) -> StringName:
	return _parentToString(parent) + DriverType.blendSpace + _indexToString(index)


# Parameter names

func parameterName(driverName : StringName, paramName : StringName) -> StringName:
	return "parameters/" + driverName + "/" + paramName


# Get animation from animation player

func animation(animationName : StringName) -> Animation:
	var anim := _animationPlayer.get_animation(animationName)

	if anim == null:
		push_error("EntityAnimationManager.animation(): Animation not found! Returning default animation.")
		return _defaultAnimation

	return anim

#endregion


#region Private functions

func _getDriver(driverName : StringName) -> AnimationNode:
	return tree_root.get_node(driverName)

func _indexToString(index : int) -> StringName:
	return StringName() if index == 0 else StringName(&" " + str(index + 1))

func _parentToString(parentName : StringName) -> StringName:
	return StringName() if parentName.is_empty() else StringName(parentName + &"/")

#endregion
