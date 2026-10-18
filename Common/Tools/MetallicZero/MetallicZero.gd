@tool
extends EditorScenePostImport

# Import script: sets "metallic" of every material in the imported scene to 0.
# Use: select the .glb in the FileSystem dock -> Import dock -> "Import Script" -> pick this file -> Reimport.


func _post_import(scene : Node) -> Object:
	var fixed := _fixNode(scene)
	print("MetallicZero: set metallic to 0 on %d materials in '%s'." % [fixed, get_source_file()])
	return scene


func _fixNode(node : Node) -> int:
	var fixed := 0

	if node is MeshInstance3D:
		var meshInstance := node as MeshInstance3D

		if meshInstance.mesh != null:
			for surface in meshInstance.mesh.get_surface_count():
				fixed += _fixMaterial(meshInstance.mesh.surface_get_material(surface))

		for surface in meshInstance.get_surface_override_material_count():
			fixed += _fixMaterial(meshInstance.get_surface_override_material(surface))

		fixed += _fixMaterial(meshInstance.material_override)

	for child in node.get_children():
		fixed += _fixNode(child)

	return fixed


func _fixMaterial(material : Material) -> int:
	if material is BaseMaterial3D and (material as BaseMaterial3D).metallic != 0.0:
		(material as BaseMaterial3D).metallic = 0.0 # Also wins over a metallic texture, the value multiplies it
		return 1

	return 0
