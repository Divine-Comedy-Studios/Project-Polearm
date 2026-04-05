@tool

extends Node3D
class_name XBotMesh


@export var _skeleton : Skeleton3D = null:
	set(skeleton):
		_skeleton = skeleton
		_resetSkeleton()


var _surface : MeshInstance3D = null
var _joints : MeshInstance3D = null


func _ready() -> void:
	_resetSkeleton()


func _resetSkeleton() -> void:
	if not is_inside_tree():
		return
	
	_surface = $Alpha_Surface as MeshInstance3D
	_joints = $Alpha_Joints as MeshInstance3D

	_surface.skeleton = _skeleton.get_path()
	_joints.skeleton = _skeleton.get_path()
