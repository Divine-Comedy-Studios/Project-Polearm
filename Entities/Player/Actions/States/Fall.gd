extends PlayerAction


@export var ACCELERATION : float = 1
@export var TERMINAL_VELOCITY : float = 20


func enterImpl() -> void:
	pass

func exitImpl() -> void:
	player.velocity.y = 0


func tickImpl(_input : PlayerInputManager.Data, _delta : float) -> void:
	player.velocity.y = maxf(player.velocity.y - ACCELERATION, -TERMINAL_VELOCITY)


func nextStateImpl(next : Type):
	if player.onGround():
		return next
	if next != Type.none and not hasHigherPriorityThan(next):
		return next
	
	return Type.none
