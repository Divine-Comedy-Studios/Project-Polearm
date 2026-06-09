extends GameState


#region Member variables

var _nextGameState : StringName = Type.none

#endregion


#region Built-in functions

func _ready() -> void:
	pass


# Handle transitioning to the pause menu
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if event is InputEventKey:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		_nextGameState = Type.paused

#endregion

func _enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit() -> void:
	_nextGameState = Type.none


func type() -> StringName:
	return Type.world

func nextState() -> StringName:
	return _nextGameState
