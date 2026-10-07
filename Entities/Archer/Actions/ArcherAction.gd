extends BasicEnemyAction
class_name ArcherAction


#region Enums

class Type:
	const none := EntityAction.Type.none


	#region Grounded states

	# Idle
	const idle := EntityAction.Type.idle
	

	# Combat can cancel out movement, but not eachother, but may be queried
	const aim := &"aim"
	const shoot := &"shoot"

	#endregion


	#region Universal states

	# Damage determines its behavior on the fly
	const damage := EntityAction.Type.damage

	# u ded lmao skill issue
	const death := &"death"

	#endregion


enum Priority {
	idle = 0,
	combatTypes = 20,
	damageTypes = 40,
}

#endregion


#region Public funcitons

func entity() -> CharacterBody3D:
	return context().entity as CharacterBody3D

func context() -> ArcherActionManager:
	return _context as ArcherActionManager

func frameData() -> BasicEnemyFrameData:
	return context().frameData as BasicEnemyFrameData

func resources() -> BasicEnemyResources:
	return context().resources as BasicEnemyResources

func animator() -> ArcherAnimator:
	return context().animator as ArcherAnimator

#endregion


#region Private functions

# Convenient function to setup the animation for states which only use the basic animation
func _animationSetupBasic() -> void:
	animator().animationDriver(
		animator().unusedHandle(&"BasicTransition")).animation = data.ANIMATION_FULL_NAME
	animator().transitionToUnused(&"BasicTransition")

#endregion
