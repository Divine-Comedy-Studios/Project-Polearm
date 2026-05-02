extends Control


#region Enums

enum LoadingState {
	notLoaded,
	loaded,
}

#endregion


#region Scene members

@onready var _godotIcon := $"CenterContainer/TextureRect" as TextureRect
@onready var _timer := $"Timer" as Timer

#endregion


#region Member variables

var _loadingState := LoadingState.notLoaded

#endregion


#region Built-in funcitons

func _ready() -> void:
	modulate.a8 = 0

func _physics_process(delta: float) -> void:
	_godotIcon.rotation += 1

	if not _timer.is_stopped():
		if _loadingState == LoadingState.loaded:
			modulate.a8 = 255 * (_timer.time_left/ _timer.wait_time)
		elif _loadingState == LoadingState.notLoaded:
			modulate.a8 = 255 * (1.0 -(_timer.time_left/ _timer.wait_time))

#endregion


#region Public funcitons

func enter() -> void:
	modulate.a8 = 255
	_timer.start()
	_loadingState = LoadingState.notLoaded
	
func exit() -> void:
	modulate.a8 = 0
	_timer.start()
	_loadingState = LoadingState.loaded

#endregion
