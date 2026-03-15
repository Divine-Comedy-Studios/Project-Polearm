# The architectual decisions and structure are heavily guided by:
#
# https://github.com/Gab-ani/Godot_Universal-Controller-tutorial/
#
# and it's accompanying YouTube tutorial series. Implementation details are customized. 
# Other state machines in the project are also inspired on this specific implementation


extends FloatingBody
class_name Player


#region Enums

enum ComboType {
	none,
	unknown = none,
	
}

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

@onready var inputManager := $InputManager as PlayerInputManager
@onready var model := $Model as PlayerModel
@onready var cameraManager := $CameraManager as PlayerCameraManager
@onready var visuals := $XBotMesh as XBotMesh

#endregion


#region Member variables

@onready var profile := PlayerProfile.new()

#endregion


#region Built-in functions

func _ready() -> void:
	init()

	cameraManager.setFollowTarget(self)
	visuals.acceptSkeleton(model.skeleton)


func _physics_process(delta: float) -> void:
	tick(delta)

#endregion
