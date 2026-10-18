extends ArcherAction


#region Exported variables

@export_group("Arrow settings")
@export var PROJECTILE_TYPE : GameObject.Type = GameObject.Type.none
@export var physics : ProjectilePhysics = null

@export_group("Shoot settings")
@export var SHOOT_OFFSET : Vector3 = Vector3.ZERO

#endregion


#region Member variables

var _shot : bool = false

#endregion


#region Override functions

func _implInit() -> void:
	assert(physics != null, "Shoot._implInit(): Projectile physics not assigned!")


func _implEnter() -> void:
	_animationSetupBasic()

	context().controller.beforeShot()

func _implExit() -> void:
	_shot = false

	context().controller.afterShot()


func _implTick(delta : float) -> void:
	super._implTick(delta) # Friction

	if not _shot and frameData().optional(data.ANIMATION_NAME, _progress):
		_shoot()

		_shot = true

#endregion


#region Private functions

func _shoot() -> void:
	physics.position = entity().to_global(SHOOT_OFFSET)

	var target := intents().target
	var dir := (target.global_position + physics.OFFSET) - physics.position

	physics.target = target
	physics.distance = dir.length()
	physics.normDirection = dir / physics.distance

	Globals.gameObjectManager.spawn(PROJECTILE_TYPE, physics)

#endregion
