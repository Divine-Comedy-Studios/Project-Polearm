@tool

extends EventTrigger
class_name EncounterTrigger


#region Member variables

var _index : int = 0

#endregion


#region Built-in functions

func _init(index : int, region : Shape3D) -> void:
	super._init()

	_index = index
	shape = region

func trigger(node : Node3D) -> void:
	if node.is_in_group("Player"):
		disable()
		Globals.world.enemyManager.beginEncounter(_index)

#endregion
