extends EntityActionManager
class_name PlayerStateMachine


#region Scene members

@export_group("Scene members")
@export var cameraManager : PlayerCameraManager = null
@export var inputManager : PlayerInputManager = null

@export var physics : PlayerPhysics = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(cameraManager != null, "PlayerStateMachine._ready(): Player camera manager not assigned!")
	assert(inputManager != null, "PlayerStateMachine._ready(): Player input manager not assigned!")

	assert(physics != null, "PlayerStateMachine._ready(): Player physics processor not assigned!")

	init()


func _physics_process(delta: float) -> void:
	_processInput(inputManager.inputs)

	tick(delta)

	entity.tick(delta)

#endregion


#region Private functions

# Input processing by sorting them by priority
func _processInput(input : PlayerInputManager.Data):
	input.actions.sort_custom(hasHigherPriority)

#endregion


#region Override functions

func _implStateInit(child : Node) -> void:
	if child is PlayerAction:
		child.init(self)
		insertAction(child)

func _initialState() -> StringName:
	return PlayerAction.Type.idle

#endregion
