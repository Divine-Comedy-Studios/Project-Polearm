extends BasicState
class_name AppState


#region Enums

class Type:
	const none := StringName()

	const loading := &"loading"

	const boot := &"boot"
	const quit := &"quit"
	const mainMenu := &"main"
	const game := &"game"

	const stageSelect := &"select"
	const world := &"world"
	const gameOver := &"gameOver"
	const paused := &"paused"

#endregion


#region Scene members

var stateMachine : AppStateMachine = null

#endregion


#region Implementation & Virtual functions

func nextState() -> StringName:
	return TYPE_NONE

func available() -> bool:
	return true

#endregion
