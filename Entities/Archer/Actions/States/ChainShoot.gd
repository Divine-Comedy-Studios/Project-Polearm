extends ArcherAction


#region Exported variables

@export_group("Arrow settings")
@export var PROJECTILE_TYPE : GameObject.Type = GameObject.Type.none
@export var physics : ProjectilePhysics = null

@export_group("Shoot settings")
@export var SHOOT_OFFSETS : Array[Vector3] = [ ]
@export var SHOOT_SPEEDS : Array[float] = [ ]
@export var HORIZONTAL_VARIATION : float = 0.0

#endregion


#region Member variables

var _shotIdx : int = 0

var _shot : bool = false

#endregion


#region Override functions

func _implInit() -> void:
	assert(physics != null, "ChainShoot._implInit(): Projectile physics not assigned!")
	assert(SHOOT_OFFSETS.size() == SHOOT_SPEEDS.size(), "ChainShoot._implInit(): Chain shot data not matching!")


func _implEnter() -> void:
	_animationSetupBasic()

	context().controller.beforeShot()

func _implExit() -> void:
	_shotIdx = 0
	_shot = false

	context().controller.afterShot()


func _implTick(delta : float) -> void:
	super._implTick(delta) # Friction

	var canShoot := frameData().optional(data.ANIMATION_NAME, _progress)

	if _shotIdx < SHOOT_OFFSETS.size() and not _shot and canShoot:
		_shoot(_shotIdx)

		_shotIdx += 1
		_shot = true

	if not canShoot: # Reset shot when the shot frame data is set to false
		_shot = canShoot

#endregion


#region Private functions

func _shoot(idx : int) -> void:
	physics.position = entity().to_global(SHOOT_OFFSETS[idx])

	physics.FLAT_SPEED = SHOOT_SPEEDS[idx]

	var target := intents().target

	var dir := (target.global_position + physics.OFFSET) - physics.position
	dir.x += randf_range(-HORIZONTAL_VARIATION, HORIZONTAL_VARIATION) * _shotIdx
	dir.z += randf_range(-HORIZONTAL_VARIATION, HORIZONTAL_VARIATION) * _shotIdx

	physics.target = target
	physics.distance = dir.length()
	physics.normDirection = dir / physics.distance

	Globals.gameObjectManager.spawn(PROJECTILE_TYPE, physics)

#endregion
