extends AnimationTree
class_name EntityAnimationManager


#region Helper structures

class DriverType:
	const simple := &"SimpleDriver"
	const uniformBlendLine := &"UniformBlendLine"
	const uniformBlendSpace := &"UniformBlendSpace"
	const uniformSimple := &"UniformSimple"


class DriverContainer extends Resource:
	var driver : AnimationNode = null

	var _name : StringName = StringName()
	var _active : bool = false


	func simple() -> AnimationNodeAnimation:
		return driver as AnimationNodeAnimation

	func uniformBlendLine() -> AnimationNodeAnimation:
		return driver as AnimationNodeBlendSpace1D

	func uniformBlendSpace() -> AnimationNodeAnimation:
		return driver as AnimationNodeBlendSpace2D

#endregion


#region Exported variables

@export var DEFAULT_ANIMATION_NAME : StringName = &""

#endregion


#region Member variables

const TRANSITION_NAME := &"transition"
const OUTPUT_NAME := &"output"


# References

@onready var _animationPlayer : AnimationPlayer = get_node(anim_player)
@onready var _defaultAnimation : Animation = get_animation(DEFAULT_ANIMATION_NAME)


# Animation tree

var _transition : AnimationNodeTransition
var _transitionSlots : Array[bool]



var _activeDriverType : StringName
var _activeDriverName : StringName

var _driverPool : Dictionary[StringName, Dictionary] = {
	DriverType.simple : { },
	DriverType.uniformBlendLine : { },
	DriverType.uniformBlendSpace : { },
	DriverType.uniformSimple : { },
}


# Root motion

@export var rootOrientation : Quaternion = Quaternion.IDENTITY

#endregion


#region Built-in functions

func _ready() -> void:
	assert(_animationPlayer != null, "EntityAnimationManager._ready(): Animation player not found!")
	assert(_defaultAnimation != null, "EntityAnimationManager._ready(): Default animation not found!")

	_initTransitionNode()

#endregion


#region Public functions

func transitionTo(driver : DriverContainer, duration : float) -> void:
	_transition.xfade_time = duration


func simple(animation : Animation) -> DriverContainer:
	pass


func uniformBlendLine() -> DriverContainer:
	pass

func uniformBlendLineSetAnimation(driver : DriverContainer, pos : float, animation : StringName) -> int:
	pass

func uniformBlendLineSetPosition(pos : float) -> void:
	pass


func uniformBlendSpace() -> DriverContainer:
	pass

func uniformBlendSpaceSetAnimation(driver : DriverContainer, pos : Vector2, animation : StringName) -> int:
	pass

func uniformBlendShapeSetPosition(pos : Vector2) -> void:
	pass


func animation(animationName : StringName) -> Animation:
	var anim := _animationPlayer.get_animation(animationName)

	if anim == null:
		push_error("EntityAnimationManager.animation(): Animation not found! Returning default animation.")
		return _defaultAnimation

	return anim

#endregion



#region Private functions

func _initTransitionNode() -> void:
	_transition = AnimationNodeTransition.new()
	_transition.input_count = 3

	tree_root.add_node(TRANSITION_NAME, _transition)
	tree_root.connect_node(TRANSITION_NAME, 0, OUTPUT_NAME)


# Get a unused driver

func _unusedSimpleDriver() -> DriverContainer:
	var container := findUnusedDriver(DriverType.simple)
	if container.driver == null:
		container.driver = AnimationNodeAnimation.new()
		container.driver.animation = DEFAULT_ANIMATION_NAME

	return container

func _unusedBlendLine() -> DriverContainer:
	var container := findUnusedDriver(DriverType.uniformBlendLine)
	if container.driver == null:
		container.driver = AnimationNodeBlendSpace1D.new()

	return container

func _unusedBlendSpace() -> DriverContainer:
	var container := findUnusedDriver(DriverType.uniformBlendSpace)
	if container.driver == null:
		container.driver = AnimationNodeBlendSpace2D.new()

	return container

func _unusedUniformSimpleDriver() -> DriverContainer:
	var container := findUnusedDriver(DriverType.uniformSimple)
	if container.driver == null:
		container.driver = AnimationNodeAnimation.new()
		container.driver.animation = DEFAULT_ANIMATION_NAME

	return container


func findUnusedDriver(driverType : StringName) -> DriverContainer:
	var pool := _driverPool.get(driverType) as Dictionary
	var poolSize := pool.size()

	for container : DriverContainer in pool:
		if not container.active:
			container.active = true
			return container


	var driverName := driverType + str(poolSize + 1)
	
	var container := DriverContainer.new()
	container.driver = null
	container._name = driverName
	container._active = true

	pool[driverName] = container

	return container


# Clean a driver and mark it for reuse

func _clearSimpleDriver(driverName : StringName) -> void:
	var driver := _deactivateDriver(DriverType.simple, driverName) as AnimationNodeAnimation

	driver.advance_on_start = false
	driver.animation = DEFAULT_ANIMATION_NAME
	driver.loop_mode = Animation.LOOP_NONE
	driver.play_mode = AnimationNodeAnimation.PLAY_MODE_FORWARD
	driver.start_offset = 0.0
	driver.stretch_time_scale = false
	driver.timeline_length = 0.0
	driver.use_custom_timeline = false

func _clearBlendLine(driverName : StringName) -> void:
	var driver := _deactivateDriver(DriverType.uniformBlendLine, driverName) as AnimationNodeBlendSpace1D

	driver.blend_mode = AnimationNodeBlendSpace1D.BLEND_MODE_INTERPOLATED

func _clearBlendSpace(driverName : StringName) -> void:
	var driver := _deactivateDriver(DriverType.uniformBlendSpace, driverName) as AnimationNodeBlendSpace2D

	driver.blend_mode = AnimationNodeBlendSpace2D.BLEND_MODE_INTERPOLATED

func _clearUniformSimpleDriver(driverName : StringName) -> void:
	var driver := _deactivateDriver(DriverType.uniformSimple, driverName) as AnimationNodeAnimation

	driver.advance_on_start = false
	driver.animation = DEFAULT_ANIMATION_NAME
	driver.loop_mode = Animation.LOOP_NONE
	driver.play_mode = AnimationNodeAnimation.PLAY_MODE_FORWARD
	driver.start_offset = 0.0
	driver.stretch_time_scale = false
	driver.timeline_length = 0.0
	driver.use_custom_timeline = false


func _deactivateDriver(driverType : StringName, driverName : StringName) -> AnimationNode:
	var driverContainer := _driverContainer(driverType, driverName)
	driverContainer.active = false

	return driverContainer.driver


# Register a driver to the tree
func _registerDriver(driverName : StringName, driver : AnimationNode) -> void:	
	tree_root.add_node(driverName, driver)

	_transition.input_count += 1
	tree_root.connect_node(driverName, _transition.input_count, TRANSITION_NAME)


# Find drivers

func _driver(driverName : StringName) -> AnimationNode:
	return tree_root.get_node(driverName)

func _driverContainer(driverType : StringName, driverName : StringName) -> DriverContainer:
	return _driverPool.get(driverType)[driverName] as DriverContainer

func _activeDriverContainer() -> DriverContainer:
	return _driverContainer(_activeDriverType, _activeDriverName)

#endregion
