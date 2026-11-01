extends AppState


#region Scene members

@onready var _background := $"Background" as ColorRect

#endregion


#region Member variables

# Add a minimum timer to the booting screen, so that it feels like as if it has a impact
@export var _minTimer : float = 1.0

#endregion


#region Built-in functions

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_INHERIT

	Globals.settingsManager.applyGameSettings()
	Globals.settingsManager.applyInputSettings("keyboard")
	Globals.settingsManager.applyInputSettings("controller")
	Globals.settingsManager.applyVideoSettings()
	Globals.settingsManager.applyAudioSettings()


func _physics_process(delta: float) -> void:
	_minTimer -= delta

#endregion


#region Override functions

func exit() -> void:
	_background.queue_free()

	process_mode = Node.PROCESS_MODE_DISABLED


func type() -> StringName:
	return Type.boot

func nextState() -> StringName:
	if _minTimer > 0.0:
		return Type.none

	return Type.mainMenu

#endregion
