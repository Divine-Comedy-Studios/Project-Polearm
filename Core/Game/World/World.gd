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


func _input(event : InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == UI_CANCEL_KEYCODE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

#endregion


#region Override functions	

func _implEnter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func delayedExit() -> void:
	_next = Type.none


func type() -> StringName:
	return Type.world

func nextState() -> StringName:
	return _next

#endregion
