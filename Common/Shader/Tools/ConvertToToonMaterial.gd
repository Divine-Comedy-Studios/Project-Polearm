@tool
extends EditorScript

## Converts the existing materials of the selected meshes into the stylized toon
## shader WITHOUT losing their colour: each mesh's albedo colour, albedo texture
## and UV transform are copied into the new ShaderMaterial.
##
## HOW TO USE
##   1. Select one or more nodes in the Scene dock (a parent works - it recurses).
##   2. Open this file in the script editor.
##   3. File > Run  (Ctrl+Shift+X / Cmd+Shift+X).
##
## Set REVERT = true and run again to strip the override materials back off,
## which restores whatever the meshes originally had.

const SHADER_PATH := "res://Common/Shader/Reference/StylizeToon.gdshader"
const REVERT := false


func _run() -> void:
	var selection := EditorInterface.get_selection().get_selected_nodes()
	if selection.is_empty():
		push_warning("Select at least one node in the Scene dock first.")
		return

	var shader := load(SHADER_PATH) as Shader
	if shader == null:
		push_error("Could not load %s" % SHADER_PATH)
		return

	var total := 0
	for node in selection:
		total += _walk(node, shader)

	if REVERT:
		print("Toon: reverted %d surface(s)." % total)
	else:
		print("Toon: converted %d surface(s). Undo with Ctrl+Z is NOT available - save first." % total)


func _walk(node: Node, shader: Shader) -> int:
	var count := 0
	if node is MeshInstance3D:
		count += _convert_mesh(node as MeshInstance3D, shader)
	for child in node.get_children():
		count += _walk(child, shader)
	return count


func _convert_mesh(mi: MeshInstance3D, shader: Shader) -> int:
	if mi.mesh == null:
		return 0

	var count := 0
	for i in mi.mesh.get_surface_count():
		if REVERT:
			if mi.get_surface_override_material(i) != null:
				mi.set_surface_override_material(i, null)
				count += 1
			continue

		var source: Material = mi.get_surface_override_material(i)
		if source == null:
			source = mi.mesh.surface_get_material(i)

		# Already converted - leave it alone.
		if source is ShaderMaterial and (source as ShaderMaterial).shader == shader:
			continue

		var mat := ShaderMaterial.new()
		mat.shader = shader

		if source is BaseMaterial3D:
			var std := source as BaseMaterial3D
			mat.set_shader_parameter("albedo_color", std.albedo_color)
			if std.albedo_texture != null:
				mat.set_shader_parameter("albedo_tex", std.albedo_texture)
			mat.set_shader_parameter("uv_scale", Vector2(std.uv1_scale.x, std.uv1_scale.y))
			mat.set_shader_parameter("uv_offset", Vector2(std.uv1_offset.x, std.uv1_offset.y))
			mat.set_shader_parameter("use_vertex_color", std.vertex_color_use_as_albedo)
		elif source is ShaderMaterial:
			# Best effort: carry over an albedo-ish parameter if the old shader had one.
			var old := source as ShaderMaterial
			for name in ["albedo_color", "albedo", "color", "modulate"]:
				var v = old.get_shader_parameter(name)
				if v is Color:
					mat.set_shader_parameter("albedo_color", v)
					break
			for name in ["albedo_tex", "albedo_texture", "texture", "main_texture"]:
				var t = old.get_shader_parameter(name)
				if t is Texture2D:
					mat.set_shader_parameter("albedo_tex", t)
					break

		mi.set_surface_override_material(i, mat)
		count += 1

	return count
