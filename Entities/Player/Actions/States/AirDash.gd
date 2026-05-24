extends PlayerBasicDash


func _implEnter() -> void:
	resources().jumpCount.value += 1

	super._implEnter()
