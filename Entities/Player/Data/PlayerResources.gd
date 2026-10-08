extends EntityResources
class_name PlayerResources


#region Exported variables

@export_group("State")
@export var godMode : bool = false
# @export var slowMotion : bool = false # 天机
@export var unlockedActions : Array[StringName]


@export_group("Resources")

@export var jumpCount : IntegerResource = null
@export var airDashed : bool = false

@export var flow : ValueResource = null

# @export var healthUpgrades : int = 0 # 3 for a full upgrade, resets to 0

# @export var inventory : Array[Items]
# @export var equipped : Array[Items]


@export_group("Modifiers")

@export var BASE_FLOW_DECREASE_RATE : float = 0.0
@export var flowModifier : float = 1

@export var FLOW_CURVE : Curve = null

#endregion


#region Built-in functions

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	flow.value -= delta * BASE_FLOW_DECREASE_RATE * flowModifier

#endregion


#region Override functions

func _reset() -> void:
	jumpCount.reset(false)
	flow.reset()

#endregion


#region Public functions

func flowToState() -> PlayerCombatManager.FlowState:
	return PlayerCombatManager.FlowState.values()[
		floori(FLOW_CURVE.sample(
			clampf(flow.value, 0, FLOW_CURVE.max_value + 0.5) # The 0.5 will still get rounded down
		)) + 1
	]

#endregion
