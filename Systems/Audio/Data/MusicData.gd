extends Resource
class_name MusicData


@export var STREAM : AudioStream = null
@export_range(-40.0, 6.0) var VOLUME_DB : float = 0.0
@export var LOOP : bool = true
## Fade time when this track starts. -1 = use the manager's default crossfade time.
@export var FADE_TIME : float = -1.0
