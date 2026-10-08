extends Resource
class_name VFXData


@export var SCENE_PATH : String = String()
## Hard cap of simultaneously playing copies. If it is reached, the oldest copy is restarted.
@export var MAX_INSTANCES : int = 8
## Copies created at load time so nothing has to be instantiated during a fight
@export var PREWARM : int = 2
