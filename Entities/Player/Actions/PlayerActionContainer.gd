extends Node
class_name PlayerActionContainer


#region Scene members

@export_group("Scene members")
@export var model : PlayerModel
# @export var physics : PlayerPhysics
@export var resources : PlayerResources
@export var combatManager : PlayerCombatManager
@export var animationPlayer : AnimationPlayer

@onready var actionData := $ActionData as PlayerActionData

var player : Player
var cameraManager : PlayerCameraManager

#endregion


#region Member variables

var actions : Dictionary[PlayerAction.Type, PlayerAction]

#endregion


#region Built-in functions

func _ready() -> void:
	assert(model != null, "PlayerActionContainer._ready(): Player model not assigned!")
	assert(resources != null, "PlayerActionContainer._ready(): Player resources not assigned!")
	assert(combatManager != null, "PlayerActionContainer._ready(): Player combat manager not assigned!")
	assert(animationPlayer != null, "PlayerActionContainer._ready(): Player skeleton animation player not assigned!")

	player = model.player

	for child in get_children():
		if child is PlayerAction:
			child.init(player, self, combatManager, actionData, resources, animationPlayer)
			actions[child.TYPE] = child

#endregion


#region Public functions

func hasHigherPriority(a : PlayerAction.Type, b : PlayerAction.Type) -> bool:
	return PlayerAction.hasHigherPriority(actions[a], actions[b])

#endregion
