extends PlayerAction


#region Member variables



#endregion


#region Override functions

func available() -> bool:
	return player().onGround() or resources().jumpCount < resources().maxJumpCount


func _implEnter() -> void:
	

	player().detachGround()



func _implExit() -> void:
	pass


func _tick(_delta : float) -> void:
	pass


func _implNextAction(next : StringName) -> StringName:
	return next

#endregion
