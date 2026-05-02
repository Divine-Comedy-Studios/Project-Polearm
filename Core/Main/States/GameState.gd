extends MainThreadLoadedScene


#region Imports

const Game := preload("res://Core/Game/Game.gd")

#endregion


#region Override functions

func _implEnter() -> void:
	super._implEnter()
	(scene as Game).enter()

func type() -> StringName:
	return Type.game

func nextState() -> StringName:
	return (scene as Game).exitState

#endregion
