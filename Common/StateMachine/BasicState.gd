extends Node
class_name BasicState


#region Constants

static var NONE := BasicState.new()
const NONE_TYPE := StringName()

#endregion


#region Virtual functions

func enter() -> void:
	pass

func exit() -> void:
	pass


func type() -> StringName:
	return NONE_TYPE

#endregion
