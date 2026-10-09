
@tool
extends Node3D
class_name LevelMesh

const WORLD_LAYER := 1 << 15
const SHADER_PATH := "res://Common/Shader/Industrial/StylizeIndustrial.gdshader"
const META_STYLED := &"level_mesh_styled"

## The master look. Edit this resource and every mesh below follows.
@export var industrial_style: ShaderMaterial:
	set(value):
		if industrial_style != null and industrial_style.changed.is_connected(_on_style_changed):
			industrial_style.changed.disconnect(_on_style_changed)

		industrial_style = value

		if industrial_style != null and not industrial_style.changed.is_connected(_on_style_changed):
			industrial_style.changed.connect(_on_style_changed)

		if is_inside_tree():
			_refresh_all()

## Re-applies the style when the game starts, so the running game always uses the current
## values of the style resource, even if the scene was not re-saved after tweaking it.
@export var apply_on_game_start: bool = true

## Use this if a change does not show up by itself.
@export_tool_button("Refresh styles", "Reload") var _refresh_button: Callable = _refresh_all_deferred

var _processing := false
var _refresh_queued := false


func _ready() -> void:
	if industrial_style != null and not industrial_style.changed.is_connected(_on_style_changed):
		industrial_style.changed.connect(_on_style_changed)

	if not Engine.is_editor_hint():
		if apply_on_game_start:
			call_deferred("_refresh_all_deferred")
		return

	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)

	call_deferred("_process_existing_children")

func _process(_delta: float) -> void:
	pass


func _process_existing_children() -> void:
	for child in get_children():
		_process_child(child)

	_refresh_all()


func _on_child_entered_tree(node: Node) -> void:
	_process_child(node)


func _process_child(node: Node) -> void:
	if _processing or not is_instance_valid(node):
		return

	if not node is Node3D:
		return

	if node.get_meta("level_mesh_collision", false):
		return

	call_deferred("_generate_collision", node)


func _generate_collision(node: Node) -> void:
	if _processing or not is_instance_valid(node):
		return

	_processing = true

	var meshes: Array[MeshInstance3D] = []
	_find_meshes(node, meshes)

	if meshes.is_empty():
		_processing = false
		return

	# Avoid creating duplicate collision bodies.
	for child in node.get_children():
		if child is StaticBody3D and child.get_meta("level_mesh_collision", false):
			_processing = false
			_refresh_all()
			return

	var static_body := StaticBody3D.new()
	static_body.name = "WorldCollision"
	static_body.collision_layer = WORLD_LAYER
	static_body.collision_mask = 0
	static_body.set_meta("level_mesh_collision", true)

	add_child(static_body)
	static_body.owner = get_tree().edited_scene_root
	static_body.global_transform = node.global_transform

	for mesh_instance in meshes:
		_create_collision(mesh_instance, static_body)

	_processing = false
	_refresh_all()


func _find_meshes(node: Node, meshes: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		meshes.append(node)

	for child in node.get_children():
		_find_meshes(child, meshes)


func _create_collision(
	mesh_instance: MeshInstance3D,
	static_body: StaticBody3D
) -> void:
	if mesh_instance.mesh == null:
		return

	var shape := mesh_instance.mesh.create_trimesh_shape()
	if shape == null:
		return

	var collision := CollisionShape3D.new()
	collision.name = mesh_instance.name + "_Collision"
	collision.shape = shape
	collision.transform = (
		static_body.global_transform.affine_inverse()
		* mesh_instance.global_transform
	)

	static_body.add_child(collision)
	collision.owner = get_tree().edited_scene_root


func _on_style_changed() -> void:
	_refresh_all()


func _refresh_all() -> void:
	if _refresh_queued:
		return

	_refresh_queued = true
	call_deferred("_refresh_all_deferred")


func _refresh_all_deferred() -> void:
	_refresh_queued = false

	for child in get_children():
		if child is Node3D and not child.get_meta("level_mesh_collision", false):
			_apply_style_recursive(child)


func _apply_style_recursive(node: Node) -> void:
	if node is MeshInstance3D:
		_apply_style_to_mesh(node)

	for child in node.get_children():
		_apply_style_recursive(child)


func _apply_style_to_mesh(mesh_instance: MeshInstance3D) -> void:
	if industrial_style == null or industrial_style.shader == null:
		return

	if mesh_instance.mesh == null:
		return

	for surface in range(mesh_instance.mesh.get_surface_count()):
		var current := mesh_instance.get_surface_override_material(surface)
		var ours := current != null and current.has_meta(META_STYLED)

		# The original is the mesh's own material, unless somebody put their own override on it.
		var original: Material = null
		if current != null and not ours:
			original = current
		else:
			original = mesh_instance.mesh.surface_get_material(surface)

		# Glass, foliage and other see-through materials stay as they are.
		if original is BaseMaterial3D and (original as BaseMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
			if ours:
				mesh_instance.set_surface_override_material(surface, null)
			continue

		var styled: ShaderMaterial = null
		if ours and current is ShaderMaterial:
			styled = current as ShaderMaterial
		else:
			styled = ShaderMaterial.new()
			styled.set_meta(META_STYLED, true)

		styled.shader = industrial_style.shader
		_copy_master_params(styled)
		_apply_original_material(original, styled)

		mesh_instance.set_surface_override_material(surface, styled)


# Copies EVERY shader parameter of the master material onto the surface material.
func _copy_master_params(target: ShaderMaterial) -> void:
	for uniform_info in industrial_style.shader.get_shader_uniform_list():
		var uniform_name: StringName = uniform_info["name"]
		var value = industrial_style.get_shader_parameter(uniform_name)

		if value == null:
			# The master has no value, so the shader default applies.
			target.set_shader_parameter(uniform_name, null)
		else:
			target.set_shader_parameter(uniform_name, value)


# Takes only what belongs to the individual surface (texture, colour, UV scale, metal, emission).
func _apply_original_material(original: Material, target: ShaderMaterial) -> void:
	if original is BaseMaterial3D:
		var standard := original as BaseMaterial3D

		target.set_shader_parameter("albedo_tex", standard.albedo_texture)
		target.set_shader_parameter("albedo_color", standard.albedo_color)
		target.set_shader_parameter("uv_scale", Vector2(standard.uv1_scale.x, standard.uv1_scale.y))
		target.set_shader_parameter("uv_offset", Vector2(standard.uv1_offset.x, standard.uv1_offset.y))
		target.set_shader_parameter("use_vertex_color", standard.vertex_color_use_as_albedo)

		if standard.uv1_triplanar:
			target.set_shader_parameter("use_triplanar", true)
			target.set_shader_parameter("triplanar_size", 1.0 / maxf(standard.uv1_scale.x, 0.001))

		var master_metal = industrial_style.get_shader_parameter("metal_amount")
		target.set_shader_parameter("metal_amount", maxf(standard.metallic, master_metal if master_metal != null else 0.0))

		if standard.emission_enabled:
			target.set_shader_parameter("emission_color", standard.emission)
			target.set_shader_parameter("emission_energy", standard.emission_energy_multiplier)

	elif original is ShaderMaterial:
		var other := original as ShaderMaterial
		if other.shader == null:
			return

		for uniform_info in other.shader.get_shader_uniform_list():
			var uniform_name: StringName = uniform_info["name"]
			var value = other.get_shader_parameter(uniform_name)

			if uniform_name in [&"albedo_tex", &"albedo_texture", &"texture_albedo", &"base_color_texture"]:
				if value is Texture2D:
					target.set_shader_parameter("albedo_tex", value)
			elif uniform_name in [&"albedo_color", &"base_color", &"base_colour"]:
				if value is Color:
					target.set_shader_parameter("albedo_color", value)
