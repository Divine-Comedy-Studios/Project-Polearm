extends EntityAction
class_name BasicEnemyAction


#region Override functions

func _enter() -> void:
	_implEnter()

func _exit() -> void:
	_implExit()


func _nextAction() -> StringName:
	return _implNextAction(_highestPriorityAction(_context.controller.intents.actions))

func _tick(delta : float) -> void:
	_implTick(delta)


func _processDirectionAngle() -> float:
	var flatInput := Vector3(_context.controller.intents.direction.x, 0.0, _context.controller.intents.direction.y)
	if flatInput.is_zero_approx():
		return 0.0

	return (-_context.entity.global_basis.z).signed_angle_to(
		flatInput,
		Vector3.UP
	)

#endregion


#region Public functions

func hurtbox() -> Hurtbox:
	return _context.hurtbox

func intents() -> BasicEnemyController.Data:
	return _context.controller.intents

#endregion


#region Implementation functions

func _implEnter() -> void:
	pass

func _implExit() -> void:
	pass

@warning_ignore("unused_parameter")
func _implTick(delta : float) -> void:
	pass


func _implNextAction(next : StringName) -> StringName:
	return next

#endregion
