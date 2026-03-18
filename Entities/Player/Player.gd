# The architectual decisions and structure are heavily guided by:
#
# https://github.com/Gab-ani/Godot_Universal-Controller-tutorial/
#
# and it's accompanying YouTube tutorial series. Implementation details are customized. 
# Other state machines in the project are also inspired on this specific implementation


extends FloatingBody
class_name Player


#region Enums

enum FlowState {
	none,
	mortal,
	cultivating,
	enlightened,
	sage,
	immortal,
	divine,
	heavenly,
}

#endregion


#region Scene Members

@onready var cameraManager := $CameraManager as PlayerCameraManager

#endregion


#region Member variables

@onready var profile := PlayerProfile.new()

#endregion


#region Built-in functions

func _ready() -> void:
	init()

	cameraManager.setFollowTarget(self)

#endregion
