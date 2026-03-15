extends PlayerAction


func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func tickImpl(_input : PlayerInputManager.Data, _delta : float) -> void:
	pass


func nextStateImpl(next : Type) -> Type:
	return next
