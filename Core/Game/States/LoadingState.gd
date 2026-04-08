extends AppState
class_name LoadingState


#region Exported variables

@export var _game : PlayingState = null

#endregion


#region Build-in functions

func _ready() -> void:
	assert(_game != null, "LoadingScreen._ready(): Playing state wasn't assigned!")

	super._ready()

#endregion


#region Override functions

func type() -> StringName:
	return Game.Type.loading

func nextState() -> StringName:
	if not scene.readyToSwitch():
		return Game.Type.none
	if not _game.finishedLoading():
		return Game.Type.none

	return Game.Type.playing

#endregion
