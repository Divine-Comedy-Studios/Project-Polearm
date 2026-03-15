extends PlayerAction


@export var ACCELERATION : float = 9.81
@export var TERMINAL_VELOCITY : float = 20


func enterImpl() -> void:
	pass

func exitImpl() -> void:
	player.velocity.y = 0


func tickImpl(_input : PlayerInputManager.Data, delta : float) -> void:
	player.velocity.y -= ACCELERATION


func nextStateImpl(next : PlayerAction.Type):
	if player.onGround():	
		return next
	if not hasHigherPriorityThan(next):
		return next
	
	return TYPE
