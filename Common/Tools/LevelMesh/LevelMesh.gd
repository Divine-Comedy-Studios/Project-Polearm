@tool
extends Node3D
class_name LevelMesh

const WORLD_LAYER := 1 << 15 # Collision Layer 16

var _processing := false


func _ready() -> void:
	if Engine.is_editor_hint():
		child_entered_tree.connect(_on_child_entered_tree)

		# Process GLBs that already exist when the scene is opened.
		call_deferred("_process_existing_children")


func _process_existing_children() -> void:
	for child in get_children():
		_process_child(child)


func _on_child_entered_tree(node: Node) -> void:
	_process_child(node)


func _process_child(node: Node) -> void:
	if _processing:
		return

	if not node is Node3D:
		return

	# Don't process our own generated collision bodies.
	if node.get_meta("level_mesh_collision", false):
		return

	# Give Godot a moment to finish loading the imported GLB.
	call_deferred("_generate_collision", node)


func _generate_collision(node: Node) -> void:
	if _processing:
		return

	if not is_instance_valid(node):
		return

	_processing = true

	var meshes: Array[MeshInstance3D] = []
	_find_meshes(node, meshes)

	if meshes.is_empty():
		_processing = false
		return

	# Don't generate duplicates.
	for child in node.get_children():
		if child is StaticBody3D and child.get_meta("level_mesh_collision", false):
			_processing = false
			return

	var static_body := StaticBody3D.new()
	static_body.name = "WorldCollision"
	static_body.collision_layer = WORLD_LAYER
	static_body.collision_mask = 0

	static_body.set_meta("level_mesh_collision", true)

	# Put the collision body alongside the GLB.
	add_child(static_body)
	static_body.owner = get_tree().edited_scene_root

	# Make collision follow the GLB's transform.
	static_body.global_transform = node.global_transform

	for mesh_instance in meshes:
		_create_collision(mesh_instance, static_body, node)

	_processing = false


func _find_meshes(node: Node, meshes: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		meshes.append(node)

	for child in node.get_children():
		_find_meshes(child, meshes)


func _create_collision(
	mesh_instance: MeshInstance3D,
	static_body: StaticBody3D,
	root_node: Node
) -> void:
	if mesh_instance.mesh == null:
		return

	var shape := mesh_instance.mesh.create_trimesh_shape()

	if shape == null:
		return

	var collision := CollisionShape3D.new()
	collision.name = mesh_instance.name + "_Collision"
	collision.shape = shape

	# Calculate the transform from the mesh to the StaticBody.
	var mesh_global := mesh_instance.global_transform
	var body_global := static_body.global_transform

	collision.transform = body_global.affine_inverse() * mesh_global

	static_body.add_child(collision)
	collision.owner = get_tree().edited_scene_root