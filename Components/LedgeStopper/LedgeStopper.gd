extends Node3D
class_name LedgeStopper


#region Imports

const LedgeStopperBlockPrefab := preload("res://Components/LedgeStopper/LedgeStopperBlock.tscn")

#endregion


#region Exported variables

@export_group("Collision settings")
@export_flags_3d_physics var DOWN_RAY_COLLISION_LAYERS : int = 0
@export_flags_3d_physics var COLLIDER_LARYERS : int = 0
@export var RAY_LENGTH : float = 0.6

@export_group("Collider arrangement settings")
@export var COLLIDER_HEIGHT : float = 1.8
@export var COLLIDER_RADIUS : float = 0.3
@export var COLLIDER_COUNT : int = 8

@export_group("Collider box settings")
@export var COLLIDER_SHAPE : Shape3D = null

#endregion


#region Scene members

@export var _remoteParent : Node3D = null

#endregion


#region Member variables

var _colliders : Array[LedgeStopperBlock] = []

var _downCastQuery : PhysicsRayQueryParameters3D

#endregion


#region Built-in functions

func _ready() -> void:
	var perBlockRotation := PI / COLLIDER_COUNT * 2
	var offset := Vector3(0.0, COLLIDER_HEIGHT, COLLIDER_RADIUS)

	_downCastQuery = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, DOWN_RAY_COLLISION_LAYERS);

	for i in range(COLLIDER_COUNT):
		var block := LedgeStopperBlockPrefab.instantiate() as LedgeStopperBlock
		block.init(offset, i * perBlockRotation, COLLIDER_SHAPE, COLLIDER_LARYERS)

		_colliders.push_back(block)
		add_child(block)


func _physics_process(_delta : float) -> void:
	if _remoteParent != null:
		position = _remoteParent.global_position

	for block : LedgeStopperBlock in _colliders:
		block.checkCollision(_downCastQuery, 4, 0.6, RAY_LENGTH)

#endregion


#region Public functions

func enable() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT

func disable() -> void:
	for collider : LedgeStopperBlock in _colliders:
		collider.disable()

	process_mode = Node.PROCESS_MODE_DISABLED


func enabled() -> bool:
	return process_mode == Node.PROCESS_MODE_INHERIT

#endregion
