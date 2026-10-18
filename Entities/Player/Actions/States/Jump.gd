extends PlayerBasicJump


#region Override functions

func _implEnter() -> void:
	player().detachGround()
	player().disableCollisionProcessing()

	resources().airDashed = false
	resources().airComboed = false
	
	super._implEnter()

func _implExit() -> void:
	player().enableCollisionProcessing()

	super._implExit()

#endregion
