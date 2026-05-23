extends PlayerBasicJump


#region Exported variables

@export var MULTI_JUMP_HEIGHT_FACTOR : float = 0.9

#endregion


#region Override functions

func _implEnter() -> void:
	for i : int in range(resources().jumpCount.value):
		jumpHeightFactor *= MULTI_JUMP_HEIGHT_FACTOR

	super._implEnter()

#endregion
