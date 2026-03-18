extends Resource
class_name PlayerCombo


enum Type {
	none,
	unknown = none,
	
}


class ActionData extends Resource:
	@export var TYPE : PlayerAction.Type
	@export var ANIMATION : String
	@export var DAMAGE : int
	@export var FLOW_MULTIPLIER : int


@export var TYPE : Type
@export var ACTIONS : Array[ActionData]
