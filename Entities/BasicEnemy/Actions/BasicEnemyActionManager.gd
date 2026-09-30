extends EntityActionManager
class_name BasicEnemyActionManager


#region Exported variables

@export_group("Enemy settings")
@export var AVAILABLE_ROLES : int = EnemyManager.Role.inactive # Could use a bitmap
@export var SERVER_COST : int = 0

#endregion


#region Member variables

var currentRole : EnemyManager.Role = EnemyManager.Role.inactive

#endregion
