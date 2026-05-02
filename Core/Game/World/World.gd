extends AppState


#region Member variables

var UI_CANCEL_KEYCODE : Key = Key.KEY_ESCAPE

var _next : StringName = Type.none

#endregion


#region Built-in functions

func _ready() -> void:
	var events := InputMap.action_get_events("ui_cancel")
	for event : InputEvent in events:
		if event is InputEventKey:
			UI_CANCEL_KEYCODE = event.keycode


func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_next = Type.paused
		if Input.is_key_pressed(UI_CANCEL_KEYCODE):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

#endregion


#region Override functions	

func enter() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func exit() -> void:
	_next = Type.none
	process_mode = Node.PROCESS_MODE_DISABLED


func type() -> StringName:
	return Type.world

func nextState() -> StringName:
	return _next

#endregion
