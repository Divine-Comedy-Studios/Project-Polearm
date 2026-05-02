@tool # Custom Scrip that allows changes the Collision Layer of any TrenchBroom generated Environments
extends FuncGodotMap

func build() -> void:

	super.build()

	for child in get_children():
		# Check if it is the worldspawn StaticBody3D node
		if child is StaticBody3D:
			# Set the collision layer to Layer 16 (Value 32768) and clear all others
			child.collision_layer = 32768
			print("Collision layer successfully set to World!")