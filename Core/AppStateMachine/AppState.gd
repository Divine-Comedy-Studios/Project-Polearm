extends BasicState
class_name AppState


#region Enums

class Type:
	const none := StringName()

	const loading := &"loading"

	const boot := &"boot"
	const quit := &"quit"
	const mainMenu := &"mainMenu"
	const game := &"game"

	const world := &"world"
	const death := &"death"
	const paused := &"paused"

#endregion


#region Exported variables

@export_file_path("*tscn", "*scn") var SCENE_PATH : String

#endregion


#region Scene members

var stateMachine : AppStateMachine = null

#endregion


#region Member variables

var _sceneResource : PackedScene = null

var scene : Node = null

#endregion


#region Built-in functions

func _ready() -> void:
	_sceneResource = load(SCENE_PATH)
	scene = _implCreateScene()

#endregion


#region Override functions

func enter() -> void:
	add_child(scene)

	process_mode = Node.PROCESS_MODE_INHERIT

	_implEnter()

func exit() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

#endregion


#region Private functions

func _unload() -> void:
	remove_child(scene)
	scene.queue_free()
	scene = null

#endregion


#region Implementation & Virtual functions

func _implCreateScene() -> Node:
	return _sceneResource.instantiate()

func _implEnter() -> void:
	pass


func nextState() -> StringName:
	return TYPE_NONE

func delayedExit() -> void:
	pass

func available() -> bool:
	return true

#endregion
