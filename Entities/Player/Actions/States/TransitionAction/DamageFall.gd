extends PlayerAction


#region Member variables

var _gravity : float = 0.0
var _terminalVelocity : float = 0.0
var _friction : float = 0.0

#endregion


#region Override functions

func _implInit() -> void:
	_gravity = physics().GRAVITY
	_terminalVelocity = physics().TERMINAL_VELOCITY
	_friction = physics().REDUCED_AERIAL_FRICTION


func _implEnter() -> void:
	_animationSetupBasic()

func _implExit() -> void:
	player().setMovementVertical(0.0)


func _implTick(delta : float) -> void:
	player().accelerateFlat(Vector2.ZERO, _friction * delta)
	player().accelerateVertical(-_terminalVelocity, _gravity * delta)


func _implNextAction(_next : StringName) -> StringName:
	if player().onGround():
		return Type.damageLanding

	return Type.none

#endregion
