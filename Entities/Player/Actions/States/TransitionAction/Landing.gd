extends PlayerAction


#region Exported variables

@export_group("Animation settings")
@export var LANDING_STILL_DATA : PlayerActionData = null
@export var LANDING_RUN_DATA : PlayerActionData = null

@export_group("Movement settings")
@export var FRICTION_MULTIPLIER : float = 0.2

#endregion


#region Member variables

# Movement settings

var _friction : float = 0.0

var _walkSpeedSquared : float = 0.0
var _runSpeedSquared : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_friction = physics().GROUNDED_FRICTION * FRICTION_MULTIPLIER

	_walkSpeedSquared = physics().WALK_FELT_SPEED
	_walkSpeedSquared *= _walkSpeedSquared

	_runSpeedSquared = physics().MAX_AERIAL_SPEED + 0.1 # Add a bit of leniency
	_runSpeedSquared *= _runSpeedSquared


func _implEnter() -> void:
	_processAnimations()


func _implTick(delta : float) -> void:
	if data == LANDING_RUN_DATA:
		#if not is_zero_approx(inputs().inputMagnitude):
		var velLen : float = PPUtil.Math.toFlatVec2(player().movement()).length()
		player().setMovementFlat3(velLen * player().forward())

		if !frameData().transitionable(data.ANIMATION_NAME, _progress):
			return
	
	player().accelerate(Vector3.ZERO, (1.0 - inputs().inputMagnitude) * _friction * delta)

func _implNextAction(next : StringName) -> StringName:
	if player().flatVelocity().length_squared() > _runSpeedSquared:
		return Type.sprintStop

	if next == Type.idle and frameData().finished(data.ANIMATION_NAME, _progress):
		return Type.none

	return next;

#endregion


#region Private functions

func _processAnimations() -> void:
	if player().flatVelocity().length_squared() > _walkSpeedSquared:
		data = LANDING_RUN_DATA
	else:
		data = LANDING_STILL_DATA

	_animationSetupBasic()

#endregion
