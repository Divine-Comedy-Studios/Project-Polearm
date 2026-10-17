extends EntityActionManager
class_name PlayerActionManager


#region Scene members

@export_group("Scene members")
@export var cameraManager : PlayerCameraManager = null
@export var inputManager : PlayerInputManager = null
@export var ledgeStopper : LedgeStopper = null

@onready var combatManager := $"CombatManager" as EntityCombatManager
@onready var physics : PlayerPhysics = $"PhysicsProcessor"

#endregion


#region Member variables

var _bufferedInputs : Dictionary[StringName, int] = { }

#endregion


#region Built-in functions

func _ready() -> void:
	assert(cameraManager != null, "PlayerActionManager._ready(): Player camera manager not assigned!")
	assert(inputManager != null, "PlayerActionManager._ready(): Player input manager not assigned!")
	assert(ledgeStopper != null, "PlayerActionManager._ready(): Player ledge stopper not assigned!")

	assert(combatManager != null, "EntityActionManager._ready(): Entity combat manager not assigned!")
	assert(physics != null, "PlayerActionManager._ready(): Player physics processor not assigned!")

	init()

func _physics_process(delta: float) -> void:
	_processActions(inputManager.inputs.actions)

	tick(delta)

#endregion


#region Override functions

func insertState(child : Node) -> void:
	if child is PlayerAction:
		var asAction := child as PlayerAction
		asAction.init(self)
		_addState(asAction)

func _initialState() -> StringName:
	return PlayerAction.Type.idle


# Input processing by sorting them by priority
func _implProcessActions(actions : Array[StringName]) -> void:
	_processInputBuffer(actions)
	_processAerialStates(actions)


func _reset() -> void:
	(entity as FloatingBody).setMovement(Vector3(0, 0, 0))
	cameraManager.reset()

#endregion


#region Private functions

func _processInputBuffer(actions : Array[StringName]) -> void:
	# Input buffers may never be repeated no matter what, only the input queue can
	if _bufferedInputs.has(currentState.TYPE):
		_bufferedInputs.erase(currentState.TYPE)

	# Insert inputs from the current batch
	for inputType : StringName in actions:
		var currentAction := action(inputType) as PlayerAction
		if currentAction.INPUT_BUFFER_FRAMES > 0:
			_bufferedInputs[currentAction.TYPE] = currentAction.INPUT_BUFFER_FRAMES

	# Process buffered inputs
	var inputsToRemove : Array[StringName] = [ ]
	for inputType : StringName in _bufferedInputs.keys():
		_bufferedInputs[inputType] -= 1
		if _bufferedInputs[inputType] < 0:
			inputsToRemove.push_back(inputType)
		elif not actions.has(inputType):
			actions.push_back(inputType)

	# Remove inputs whose frame buffering ran out
	for inputType : StringName in inputsToRemove:
		_bufferedInputs.erase(inputType)


func _processAerialStates(actions : Array[StringName]) -> void:
	if (entity as FloatingBody).onGround():
		resources.jumpCount.value = 0
		resources.airDashed = false

		return
	
	var aerialInputs : Array[StringName] = []
	for input : StringName in actions:
		var aerial := PlayerAction.Type.TO_AIR.get(input, PlayerAction.Type.none) as StringName
		if aerial == PlayerAction.Type.none:
			continue
		if aerialInputs.has(aerial):
			continue
		
		aerialInputs.push_back(aerial)

	actions.assign(aerialInputs)

#endregion
