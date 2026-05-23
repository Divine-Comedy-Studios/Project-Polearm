extends PlayerBasicJump


#region Override functions

func _implEnter() -> void:
	player().detachGround()
	player().disableCollisionProcessing()
	
	super._implEnter()

func _implExit() -> void:
	player().enableCollisionProcessing()

	super._implExit()

#endregion
