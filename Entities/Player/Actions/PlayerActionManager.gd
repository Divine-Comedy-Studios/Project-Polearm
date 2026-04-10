extends EntityActionManager
class_name PlayerActionManager


#region Scene members

@export_group("Scene members")
@export var cameraManager : PlayerCameraManager = null
@export var inputManager : PlayerInputManager = null

@export var physics : PlayerPhysics = null

#endregion


#region Member variables

var _bufferedInputs : Dictionary[StringName, int] = { }

#endregion


#region Built-in functions

func _ready() -> void:
	assert(cameraManager != null, "PlayerStateMachine._ready(): Player camera manager not assigned!")
	assert(inputManager != null, "PlayerStateMachine._ready(): Player input manager not assigned!")

	assert(physics != null, "PlayerStateMachine._ready(): Player physics processor not assigned!")

	init()


func _physics_process(delta: float) -> void:
	_processInputs()

	tick(delta)

	entity.tick(delta)

#endregion


#region Private functions

# Input processing by sorting them by priority
func _processInputs():
	if _bufferedInputs.has(currentState.TYPE): # Erase the input buffer from last frame which has been chosen
		_bufferedInputs.erase(currentState.TYPE)

	# Insert inputs from the current batch
	for inputType : StringName in inputManager.inputs.actions:
		var currentAction := action(inputType)
		if not currentAction is PlayerAction:
			continue

		if currentAction.INPUT_BUFFER_FRAMES > 0:
			_bufferedInputs[currentAction.TYPE] = currentAction.INPUT_BUFFER_FRAMES

	# Process all buffered inputs and decrement their frame counter
	var inputsToRemove : Array[StringName] = [ ]
	for inputType : StringName in _bufferedInputs.keys():
		_bufferedInputs[inputType] -= 1
		if _bufferedInputs[inputType] < 0:
			inputsToRemove.push_back(inputType)

		# The input may be still added on the frame it should be removed, as frame subtraction happens first
		if not inputManager.inputs.actions.has(inputType):
			inputManager.inputs.actions.push_back(inputType)

	# Remove buffered inputs which can't be executed anymore
	for inputType : StringName in inputsToRemove:
		_bufferedInputs.erase(inputType)

	# Sort current inputs
	inputManager.inputs.actions.sort_custom(hasHigherPriority)

#endregion


#region Override functions

func _implStateInit(child : Node) -> void:
	if child is PlayerAction:
		child.init(self)
		insertAction(child)

func _initialState() -> StringName:
	return PlayerAction.Type.idle

#endregion
