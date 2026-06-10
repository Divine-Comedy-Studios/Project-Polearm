extends EntityActionManager
class_name PlayerActionManager


#region Scene members

@export_group("Scene members")
@export var cameraManager : PlayerCameraManager = null
@export var inputManager : PlayerInputManager = null

@onready var physics : PlayerPhysics = $"PhysicsProcessor"

#endregion


#region Member variables

var _bufferedInputs : Dictionary[StringName, int] = { }

var _actionForced : StringName = PlayerAction.Type.none
var _actionQueue : StringName = PlayerAction.Type.none

#endregion


#region Built-in functions

func _ready() -> void:
	assert(entity is Player, "PlayerActionManager._ready(): The entity must be a Player!")
	assert(cameraManager != null, "PlayerActionManager._ready(): Player camera manager not assigned!")
	assert(inputManager != null, "PlayerActionManager._ready(): Player input manager not assigned!")
	assert(physics != null, "PlayerActionManager._ready(): Player physics processor not assigned!")

	init()


func _physics_process(delta: float) -> void:
	_processInputs()

	tick(delta)

	entity.tick(delta)

#endregion


#region Override functions

func insertState(child : Node) -> void:
	if child is PlayerAction:
		child.init(self)
		_addState(child)

func _initialState() -> StringName:
	return PlayerAction.Type.move

#endregion


#region Public functions

func pushActionQueue(queue : StringName) -> void:
	_actionQueue = queue

func popActionQueue() -> StringName:
	var queue := _actionQueue
	_actionQueue = PlayerAction.Type.none
	return queue


func pushActionForced(queue : StringName) -> void:
	_actionForced = queue

func popActionForced() -> StringName:
	var queue := _actionForced
	_actionForced = PlayerAction.Type.none
	return queue

#endregion


#region Private functions

# Input processing by sorting them by priority
func _processInputs():
	if _actionForced != PlayerAction.Type.none:
		inputManager.inputs.actions = [ popActionForced() ]
		
	else:
		_processActionQueue()
		_processInputBuffer()
		_processAerialStates()

		# Sort current inputs
		inputManager.inputs.actions.sort_custom(hasHigherPriority)


func _processInputBuffer() -> void:
	# Input buffers may never be repeated no matter what, only the input queue can
	if _bufferedInputs.has(currentState.TYPE):
		_bufferedInputs.erase(currentState.TYPE)

	# Insert inputs from the current batch
	for inputType : StringName in inputManager.inputs.actions:
		var currentAction := action(inputType) as PlayerAction
		if currentAction.INPUT_BUFFER_FRAMES > 0:
			_bufferedInputs[currentAction.TYPE] = currentAction.INPUT_BUFFER_FRAMES

	# Process buffered inputs
	var inputsToRemove : Array[StringName] = [ ]
	for inputType : StringName in _bufferedInputs.keys():
		_bufferedInputs[inputType] -= 1
		if _bufferedInputs[inputType] < 0:
			inputsToRemove.push_back(inputType)
		elif not inputManager.inputs.actions.has(inputType):
			inputManager.inputs.actions.push_back(inputType)

	# Remove inputs whose frame buffering ran out
	for inputType : StringName in inputsToRemove:
		_bufferedInputs.erase(inputType)


func _processActionQueue() -> void:
	if (_actionQueue != PlayerAction.Type.none and
		not inputManager.inputs.actions.has(_actionQueue)):
		inputManager.inputs.actions.push_back(_actionQueue)
		_actionQueue = PlayerAction.Type.none


func _processAerialStates() -> void:
	if (entity as Player).onGround():
		resources.jumpCount.value = 0
		resources.airDashed = false

		return
	
	var aerialInputs : Array[StringName] = []
	for input : StringName in inputManager.inputs.actions:
		var aerial := PlayerAction.Type.TO_AIR.get(input, PlayerAction.Type.none) as StringName
		if aerial == PlayerAction.Type.none:
			continue
		if aerialInputs.has(aerial):
			continue
		
		aerialInputs.push_back(aerial)

	inputManager.inputs.actions = aerialInputs

#endregion
