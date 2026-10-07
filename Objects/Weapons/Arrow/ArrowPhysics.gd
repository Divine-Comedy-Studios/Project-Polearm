extends Resource
class_name ArrowPhysics


#region Exported variables

@export_group("Arrow settings")
@export var FLAT_SPEED : float = 40
@export var LIFETIME : float = 4.0
@export var GRAVITY : float = 20.0
@export var HIT_DATA : HitboxData = null

#endregion


#region Member variables

var position : Vector3 = Vector3.ZERO
var entityPosition : Vector3 = Vector3.ZERO

var distance : float = 0.0 # Distance from the position to the point which is aimed at
var normDirection : Vector3 = Vector3.ZERO # Direction from the position to the point which is aimed at

#endregion
