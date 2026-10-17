extends Resource
class_name Wave


@export_group("Enemy config")
@export var MAX_ENEMY_COUNT : int = 4
@export var ENEMIES : Array[GameObject.Type] = [ ]

@export_group("Wave behavior config")
@export var BREAK_TIME_SEC : float = 0.5
@export var MAX_ROLE_DIFFICULTY : float = 10.0
@export var ROLE_DIFFICULTY_RANDOMIZATION : float = 2
@export var REQUIRED_ROLES : Dictionary[EnemyManager.Role, int] = { }

@export_group("DEBUG")
@export var ENEMY_POSITIONS : Dictionary[int, Vector3] = { }
