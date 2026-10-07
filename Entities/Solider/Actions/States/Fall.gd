extends SoliderAction


#region Exported variables

@export_group("Gravity settings")
@export var FALL_GRAVITY : float = 80.0
@export var TERMINAL_VELOCITY : float = 30.0

@export_group("Movement settings")
@export var AERIAL_FRICTION : float = 5.0

#endregion


#region Override functions

func _implEnter() -> void:
	_animationSetupBasic()

func _implExit() -> void:
	entity().setMovementVertical(0.0)


func _implTick(delta : float) -> void:
	entity().accelerateFlat(Vector2.ZERO, AERIAL_FRICTION * delta)
	entity().accelerateVertical(-TERMINAL_VELOCITY, FALL_GRAVITY * delta)

#endregion
