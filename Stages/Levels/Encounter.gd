extends EncounterScript

@export var _door1 : Door = null
@export var _door2 : Door = null

func begin()->void:
	_door1.activate()
	_door2.activate()
	

func end()-> void:
	_door2.deactivate()
