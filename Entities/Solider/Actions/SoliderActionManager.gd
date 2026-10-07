extends BasicEnemyActionManager
class_name SoliderActionManager


#region Override functions

func _implProcessActions(actions : Array[StringName]) -> void:
	if (entity as FloatingBody).onGround():
		return

	var aerialInputs : Array[StringName] = []
	for input : StringName in actions:
		var aerial := SoliderAction.Type.TO_AIR.get(input, SoliderAction.Type.none) as StringName
		if aerial == SoliderAction.Type.none:
			continue
		if aerialInputs.has(aerial):
			continue

		aerialInputs.push_back(aerial)

	actions.assign(aerialInputs)


func _reset() -> void:
	(entity as FloatingBody).setMovement(Vector3(0, 0, 0))

#endregion
