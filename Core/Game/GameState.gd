extends AppState
class_name GameState


#region Member variables

var _payload : Variant = null

#endregion


#region Public functions

func popPayload() -> Variant:
	var tmp : Variant = _payload
	_payload = null
	return tmp

#endregion


#region Override functions

func enter() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	_enter()

func exit() -> void:
	_exit()
	process_mode = Node.PROCESS_MODE_DISABLED

#endregion


#region Virtual functions

func _enter() -> void:
	pass

func _exit() -> void:
	pass

#endregion
