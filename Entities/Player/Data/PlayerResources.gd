extends EntityResources
class_name PlayerResources


#region Exported variables

@export_group("States")

@export var godMode : bool = false

@export var slowMotion : bool = false # 天机

@export var sonOfHeaven : bool = false

@export var unlockedActions : Array[StringName]


@export_group("Resources")

@export var MAX_FLOW : float = 1000

@export var spirits : int = 0 # 魄
@export var healthUpgrades : int = 0 # 3 for a full upgrade

# @export var inventory : Array[Items]


@export_group("Modifiers")

# @export var witchModeTime : float # Duration of witch mode

@export var BASE_FLOW_DECREASE_RATE : float
@export var flowModifier : float = 1

@export var FLOW_CURVE : Curve

#endregion


#region Member variables

var flow : float = 0.0:
	get:
		return flow
	set(value):
		flow = clampf(value, 0.0, MAX_FLOW)

#endregion


#region Built-in functions

func _physics_process(delta: float) -> void:
	flow -= delta * BASE_FLOW_DECREASE_RATE * flowModifier

#endregion


#region Public functions

func flowToState() -> PlayerCombatManager.FlowState:
	return PlayerCombatManager.FlowState.values()[floori(FLOW_CURVE.sample(clampf(flow, 0, FLOW_CURVE.max_value + 0.5)))]

#endregion
