extends BasicState
class_name AppState


#region Enums

class Type:
	const none := StringName()

	const loading := &"loading"

	const boot := &"boot"
	const quit := &"quit"
	const mainMenu := &"mainMenu"
	const game := &"game"

	const world := &"world"
	const death := &"death"
	const paused := &"paused"

#endregion


#region Scene members

var stateMachine : AppStateMachine = null

#endregion


#region Implementation & Virtual functions

func _implEnter() -> void:
	pass


func nextState() -> StringName:
	return TYPE_NONE


func available() -> bool:
	return true

#endregion
