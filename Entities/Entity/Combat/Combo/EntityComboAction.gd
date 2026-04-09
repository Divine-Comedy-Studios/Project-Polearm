extends RefCounted
class_name EntityComboAction


#region Member variables

var COMBO_TYPE : StringName = StringName() # Only set to a valid combo type if the action is the last in a chain
var tree : Dictionary[StringName, EntityComboAction] = { }

var DATA : EntityActionData = null

#endregion


#region Functions

func _init(data_ : EntityActionData) -> void:
	self.DATA = data_

#endregion
