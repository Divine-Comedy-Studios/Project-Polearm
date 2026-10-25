extends BasicLoadingScreen


#region Enums

enum LoadingState {
	notLoaded,
	loaded,
}

#endregion


#region Scene members

@onready var _Icon := $"CenterContainer/Control/TextureRect" as TextureRect
@onready var _timer := $"Timer" as Timer

#endregion


#region Member variables

var _loadingState := LoadingState.notLoaded

#endregion


#region Built-in funcitons

func _ready() -> void:
	modulate.a8 = 255

func _physics_process(delta : float) -> void:
	_Icon.rotation += delta

	if _timer.is_stopped():
		modulate.a8 = 255 if _loadingState == LoadingState.notLoaded else 0
	elif _loadingState == LoadingState.loaded:
		modulate.a8 = int(255 * (_timer.time_left / _timer.wait_time))
	elif _loadingState == LoadingState.notLoaded:
		modulate.a8 = int(255 * (1.0 -(_timer.time_left / _timer.wait_time)))

#endregion


#region Public funcitons

func enter() -> void:
	_timer.start()
	_loadingState = LoadingState.notLoaded
	
func exit() -> void:
	_timer.start()
	_loadingState = LoadingState.loaded

#endregion
