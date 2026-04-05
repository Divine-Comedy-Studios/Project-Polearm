extends Node
class_name PlayerActionManager


#region Scene members

@export_group("Scene members")
@export var player : Player

@export var cameraManager : PlayerCameraManager
@export var inputManager : PlayerInputManager

@export var resources : PlayerResources
@export var actionData : PlayerActionData

@export var physics : PlayerPhysics

@export var combatManager : PlayerCombatManager

@export var animationPlayer : AnimationPlayer

#endregion


#region Member variables

var actions : Dictionary[PlayerAction.Type, PlayerAction]

var currentAction : PlayerAction = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(player != null, "PlayerActionManager._ready(): Player not assigned!")

	assert(cameraManager != null, "PlayerActionManager._ready(): Player camera manager not assigned!")
	assert(inputManager != null, "PlayerActionManager._ready(): Player input manager not assigned!")

	assert(resources != null, "PlayerActionManager._ready(): Player resources not assigned!")
	assert(actionData != null, "PlayerActionManager._ready(): Player action data not assigned!")

	assert(physics != null, "PlayerActionManager._ready(): Player physics processor not assigned!")

	assert(combatManager != null, "PlayerActionManager._ready(): Player combat manager not assigned!")

	assert(animationPlayer != null, "PlayerActionManager._ready(): Player skeleton animation player not assigned!")

	for child in get_children():
		if child is PlayerAction:
			child.init(player, self, combatManager, actionData, resources, animationPlayer)
			actions[child.TYPE] = child

	enterAction(PlayerAction.Type.idle)


func _physics_process(delta: float) -> void:
	_processInput(inputManager.inputs)

	var nextActionType := currentAction.nextAction(inputManager.inputs)
	if nextActionType != PlayerAction.Type.none:
		exitCurrentAction()
		enterAction(nextActionType)

	currentAction.tick(inputManager.inputs, delta)

	player.tick(delta)

#endregion


#region Public functions

func exitCurrentAction() -> void:
	currentAction.exit()

func enterAction(type : PlayerAction.Type) -> void:
	currentAction = actions[type]
	currentAction.enter()


func hasHigherPriority(a : PlayerAction.Type, b : PlayerAction.Type) -> bool:
	return PlayerAction.hasHigherPriority(actions[a], actions[b])

#endregion


#region Private functions

# Input processing by sorting them by priority
func _processInput(input : PlayerInputManager.Data):
	input.actions.sort_custom(hasHigherPriority)

#endregion
