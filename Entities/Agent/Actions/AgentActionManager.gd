extends EntityActionManager
class_name AgentActionManager


#region Exported variables

@export_group("Agent settings")
@export var AVAILABLE_ROLES : Array[AgentServer.Role] = AgentServer.Role.inactive # Could use a bitmap
@export var SERVER_COST : int = 0

#endregion


#region Member variables

var currentRole : AgentServer.Role = AgentServer.Role.inactive

#endregion
