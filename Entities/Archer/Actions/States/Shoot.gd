extends ArcherAction


#region Exported variables

@export_group("Arrow settings")
@export var SCENE : PackedScene = null
@export var physics : ArrowPhysics = null

@export_group("Shoot settings")
@export var SHOOT_OFFSET : Vector3 = Vector3.ZERO
@export var TARGET_OFFEST : Vector3 = Vector3.ZERO

#endregion


#region Member variables

var _shot : bool = false

#endregion


#region Override functions

func _implInit() -> void:
	assert(SCENE != null, "Shooter Shoot._implInit(): Arrow scene not assigned!")
	assert(physics != null, "Shooter Shoot._implInit(): Arrow physics not assigned!")


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

	var dir := (intents().targetPosition + TARGET_OFFEST) - physics.position
	physics.distance = dir.length()
	physics.normDirection = dir / physics.distance

	Globals.world.gameObjectManager.spawn(GameObject.Type.arrow, physics)

#endregion
