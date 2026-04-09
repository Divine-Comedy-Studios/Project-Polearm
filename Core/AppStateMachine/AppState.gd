extends BasicState
class_name AppState


#region Exported variables

@export_file_path("*tscn", "*scn") var SCENE_PATH : String

#endregion


#region Member variables

var _sceneResource : PackedScene = null

var scene : Node = null

#endregion


#region Built-in functions

func _ready() -> void:
	_sceneResource = load(SCENE_PATH)

#endregion


#region Member functions

func enter() -> void:
	scene = _implCreateScene()
	add_child(scene)

	process_mode = Node.PROCESS_MODE_INHERIT

	_implEnter()

func exit() -> void:
	_implExit()

	process_mode = Node.PROCESS_MODE_DISABLED

	remove_child(scene)
	scene.queue_free()
	scene = null

#endregion


#region Implementation & Virtual functions

func _implCreateScene() -> Node:
	return _sceneResource.instantiate()

func _implEnter() -> void:
	pass

func _implExit() -> void:
	pass


func nextState() -> StringName:
	return NONE_TYPE

#endregion
