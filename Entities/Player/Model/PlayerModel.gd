extends Node3D
class_name PlayerModel


#region Scene members

@export_group("Scene members")
@export var player : Player
@export var inputManager : PlayerInputManager

@onready var actionContainer := $ActionContainer as PlayerActionContainer
@onready var combatManager := $CombatManager as PlayerCombatManager
@onready var resources := $Resources as PlayerResources
@onready var skeleton := $Skeleton as Skeleton3D
# @onready var physics := $Physics as PlayerPhysics

#endregion


#region Member variables

var currentAction : PlayerAction = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(player != null, "PlayerModel._ready(): Player player not assigned!")

	currentAction = actionContainer.actions[PlayerAction.Type.idle]
	switchTo(PlayerAction.Type.idle)

#endregion


#region Public functions

func _physics_process(delta: float) -> void:
	processInput(inputManager.inputs)
	
	var nextAction := currentAction.nextAction(inputManager.inputs)
	if nextAction != PlayerAction.Type.none:
		switchTo(nextAction)
	
	currentAction.tick(inputManager.inputs, delta)
	# combatManager.tick(delta)
	# resources.tick(delta)


# Input processing by sorting them by priority
func processInput(input : PlayerInputManager.Data):
	input.actions.sort_custom(actionContainer.hasHigherPriority)
	
	# Check sidearm --> What did I mean by this?


# Forces a swith to a given action type
func switchTo(action : PlayerAction.Type) -> void:
	currentAction.exit()
	currentAction = actionContainer.actions[action]
	currentAction.enter()

#endregion
