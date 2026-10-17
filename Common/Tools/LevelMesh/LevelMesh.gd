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

## "Buttons": tick one of these in the inspector, it runs once and unticks itself.
## (Plain checkboxes on purpose, they are more robust than tool buttons when the script gets reloaded.)

## Use this if a style change does not show up by itself.
@export var refresh_styles_now: bool = false:
	set(value):
		if value and is_inside_tree():
			_refresh_all_deferred()

## Builds the collision for everything below this node. Nothing is created automatically.
## Ticking it again rebuilds the collision from scratch (old generated bodies are removed first).
@export var create_collision_now: bool = false:
	set(value):
		if value and is_inside_tree():
			create_collision()

## Removes all collision that this node generated.
@export var remove_collision_now: bool = false:
	set(value):
		if value and is_inside_tree():
			remove_collision()

var _refresh_queued := false


func _ready() -> void:
	if industrial_style != null and not industrial_style.changed.is_connected(_on_style_changed):
		industrial_style.changed.connect(_on_style_changed)

	if not Engine.is_editor_hint():
		if apply_on_game_start:
			call_deferred("_refresh_all_deferred")
		return

	# New children get the style automatically. Collision is only created with the button.
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)

	call_deferred("_refresh_all")


func _on_child_entered_tree(_node: Node) -> void:
	_refresh_all()


# --- collision (only when the button is pressed) ----------------------------------------

func create_collision() -> void:
	remove_collision()

	var scene_root := get_tree().edited_scene_root if Engine.is_editor_hint() else owner
	var created_bodies := 0
	var created_shapes := 0

	for child in get_children():
		if not child is Node3D or child.get_meta("level_mesh_collision", false):
			continue

		var meshes: Array[MeshInstance3D] = []
		_find_meshes(child, meshes)
		if meshes.is_empty():
			continue

		var static_body := StaticBody3D.new()
		static_body.name = "WorldCollision_" + String(child.name)
		static_body.collision_layer = WORLD_LAYER
		static_body.collision_mask = 0
		static_body.set_meta("level_mesh_collision", true)

		add_child(static_body)
		static_body.owner = scene_root
		static_body.global_transform = (child as Node3D).global_transform
		created_bodies += 1

		for mesh_instance in meshes:
			if _create_collision(mesh_instance, static_body, scene_root):
				created_shapes += 1

	print("LevelMesh: created %d collision shapes in %d bodies. Save the scene to keep them." % [created_shapes, created_bodies])


func remove_collision() -> void:
	var removed := 0

	for child in get_children():
		if child is StaticBody3D and child.get_meta("level_mesh_collision", false):
			remove_child(child)
			child.queue_free()
			removed += 1

	if removed > 0:
		print("LevelMesh: removed %d old collision bodies." % removed)


func _find_meshes(node: Node, meshes: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		meshes.append(node)

	for child in node.get_children():
		_find_meshes(child, meshes)


func _create_collision(
	mesh_instance: MeshInstance3D,
	static_body: StaticBody3D,
	scene_root: Node
) -> bool:
	if mesh_instance.mesh == null:
		return false

	var shape := mesh_instance.mesh.create_trimesh_shape()
	if shape == null:
		return false

	var collision := CollisionShape3D.new()
	collision.name = String(mesh_instance.name) + "_Collision"
	collision.shape = shape

	static_body.add_child(collision)
	collision.owner = scene_root
	collision.global_transform = mesh_instance.global_transform
	return true


# --- style -----------------------------------------------------------------------------

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
