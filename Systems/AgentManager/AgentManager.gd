extends Node
class_name AgentManager


#region Enums

enum Role {
	inactive,
	dummy,

	fighter,
	flanker,
	circler,
	ranged,
	any,

	boss,
}

#endregion


#region Constants

const ROLE_COST_MULTIPLIER_INACTIVE : float = 0.0
const ROLE_COST_MULTIPLIER_DUMMY : float = 0.0

#endregion


#region Exported variables

@export_group("AI settings")
@export var ROLE_COST_MULTIPLIER_FIGHTER : float = 1.0
@export var ROLE_COST_MULTIPLIER_FLANKER : float = 1.0
@export var ROLE_COST_MULTIPLIER_CIRCLER : float = 1.0
@export var ROLE_COST_MULTIPLIER_RANGED : float = 1.0
@export var ROLE_COST_MULTIPLIER_ANY : float = 1.0

#endregion


#region Member variables

@export var value : IntegerResource = null

var _activeAgents : Dictionary[int, IndieBlueprintObjectPoolWrapper] = { }
var _pools : Dictionary[PPUtil.ObjectType, IndieBlueprintObjectPool]

#endregion


#region Built-in functions

func _ready() -> void:
	assert(value != null, "AgentServer._ready(): Please assign a value container to the server!")


func _physics_process(delta : float) -> void:
	for agent : IndieBlueprintObjectPoolWrapper in _activeAgents.values():
		pass

#endregion


#region Public functions

func registerAgentType(type : PPUtil.ObjectType, pool : IndieBlueprintObjectPool) -> void:
	_pools[type] = pool

func spawnAgent(type : PPUtil.ObjectType, position : Vector3) -> void:
	var agentWrapper := _pools[type].spawn() # Not statically typed
	var id := agentWrapper.instance.get_instance_id()
	_activeAgents[id] = agentWrapper

	var agent = _castToEntity(type, agentWrapper.instance as Node3D)
	agent.reset()
	agent.position = position
	agent.currentRole = _assignAgentRole(agent.AVAILABLE_ROLES)


func killAgent(id : int) -> void:
	_activeAgents[id].kill()
	_activeAgents.erase(id)

#endregion


#region Private functions

func _castToEntity(type : PPUtil.ObjectType, node : Node3D) -> Variant:
	return null

func _assignAgentRole(available : Array[Role]) -> Role:
	return Role.inactive

#endregion
