extends InterfaceState


#region Scene members

@export var _fadeInTimer : Timer = null
@export var _fadeOutTimer : Timer = null
@export var _fadeRect : ColorRect = null

#endregion


#region Member variables

var _respawnPressed : bool = false
var _mainMenuPressed : bool = false

#endregion


#region Built-in functions

func _ready() -> void:
	assert(_fadeInTimer != null, "Death._ready(): Fade in timer not assigned!")
	assert(_fadeOutTimer != null, "Death._ready(): Fade out timer not assigned!")
	assert(_fadeRect != null, "Death._ready(): Fade color rect not assigned!")


func _physics_process(_delta: float) -> void:
	if not _fadeInTimer.is_stopped():
		modulate.a = 1 - _fadeInTimer.time_left / _fadeInTimer.wait_time
	if not _fadeOutTimer.is_stopped():
		_fadeRect.color.a = 1 - _fadeOutTimer.time_left / _fadeOutTimer.wait_time

#endregion


#region Implementation functions

func activate() -> void:
	super.activate()

	modulate.a = 0.0
	_fadeInTimer.start()

	Globals.audioManager.playMusic(MusicData.Type.death)


func _implDeactivate() -> void:
	_respawnPressed = false
	_mainMenuPressed = false

	_fadeRect.visible = false
	_fadeRect.color.a = 0.0

func exit() -> StringName:
	if _fadeOutTimer.is_stopped():
		if _respawnPressed:
			return AppState.Type.world

		if _mainMenuPressed:
			return AppState.Type.mainMenu

	return AppState.Type.none


func type() -> Type:
	return Type.death

#endregion


#region Signal functions

func _on_respawn_pressed() -> void:
	_respawnPressed = true

	_startExitTimer()

func _on_main_menu_pressed() -> void:
	_mainMenuPressed = true

	_startExitTimer()

#endregion


#region Private functions

func _startExitTimer() -> void:
	_fadeRect.visible = true

	_fadeOutTimer.start()

#endregion
