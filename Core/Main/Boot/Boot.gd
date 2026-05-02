extends AppState


#region Member variables

@export var _timer : float = 1.0

#endregion


#region Built-in functions

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(delta: float) -> void:
	_timer -= delta

#endregion


#region Override functions

func exit() -> void:
	queue_free()


func type() -> StringName:
	return Type.boot

func nextState() -> StringName:
	if _timer > 0.0:
		return Type.none

	return Type.mainMenu

#endregion
