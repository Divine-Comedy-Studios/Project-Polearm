extends RefCounted
class_name PlayerComboAction


# Only set to a valid combo type if the action is the last in a chain
var FINAL_ATTACK_MARKER : PlayerCombo.Type = PlayerCombo.Type.none
var DATA : PlayerCombo.ActionData

var tree : Dictionary[PlayerCombo.Type, PlayerComboAction] = { }


func _init(data : PlayerCombo.ActionData = PlayerCombo.ActionData.new()) -> void:
	self.DATA = data
