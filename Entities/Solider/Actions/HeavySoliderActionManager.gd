
extends SoliderActionManager


#region Override functions

func interrupt(type : StringName) -> void:
	if type == SoliderAction.Type.damage: # Heavy solider doesn't get knockback
		return
	
	super.interrupt(type)

#endregion
