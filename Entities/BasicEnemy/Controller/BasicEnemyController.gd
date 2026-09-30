extends Node
class_name BasicEnemyController


#region Helper structures

# Input data container
class Data extends RefCounted:
	var magnitude : float
	var direction : Vector2

	var actions : Array[StringName]
	var modifiers : Array[StringName]
	
	func reset() -> void:
		magnitude = 0.0
		direction = Vector2.ZERO

		actions.clear()
		modifiers.clear()

#endregion


#region Exported variables

@export_group("Config")


#endregion


#region Member variables

var intents : Data = Data.new()

#endregion


#region Built-in functions

func _physics_process(_delta : float) -> void:
	intents.reset()

	# Add default options
	intents.actions.append(DummyEnemyAction.Type.idle)

#endregion
