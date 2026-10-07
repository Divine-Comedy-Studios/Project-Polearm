extends PlayerBasicStopAction


#region Exported variables

@export_group("Animation settings")
@export var AERIAL_DAMAGE_DATA : EntityActionData = null
@export var GROUND_DAMAGE_DATA : EntityActionData = null

#endregion



#region Override functions

func _implInit() -> void:
	super._implInit()

	assert(AERIAL_DAMAGE_DATA != null, "Player Damage._implInit(): Aerial damage action data not assigned")
	assert(GROUND_DAMAGE_DATA != null, "Player Damage._implInit(): Aerial damage action data not assigned")

	data = GROUND_DAMAGE_DATA


func _implEnter() -> void:
	if player().onGround():
		if resources().health.value <= 0.0:
			context().interrupt(Type.death)

			return

		data = GROUND_DAMAGE_DATA
	else:
		player().setMovementVertical(0.0)

		data = AERIAL_DAMAGE_DATA

	_animationSetupBasic()


func _implNextAction(next : StringName) -> StringName:
	if data == AERIAL_DAMAGE_DATA:
		if player().onGround():
			return Type.damageLanding

		return Type.damageFall

	if next != Type.none:
		return next

	return Type.none

#endregion
