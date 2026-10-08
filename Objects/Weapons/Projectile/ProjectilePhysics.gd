extends Resource
class_name ProjectilePhysics


#region Exported variables

@export_group("Arrow settings")
@export var FLAT_SPEED : float = 40
@export var LIFETIME : float = 4.0
@export var GRAVITY : float = 20.0
@export var OFFSET : Vector3 = Vector3.ZERO

#endregion


#region Member variables

var position : Vector3 = Vector3.ZERO
var entityPosition : Vector3 = Vector3.ZERO

var target : Node3D = null

var distance : float = 0.0
var normDirection : Vector3 = Vector3.ZERO

#endregion
