extends PlayerBasicStopAction


#region Exported variables

@export var IDLE_DATA : PlayerActionData = null

#endregion


#region Override functions

func _implEnter() -> void:
	# Calculate factors to blend the animations between their different states
	var normRange := clampf(
		PPUtil.Math.toRangeNormalized(
			PPUtil.Math.toFlatVec2(player().velocity).length(), 
			physics().WALK_FELT_SPEED,
			physics().RUN_SPEED),
		0.0, 1.0)

	# Setup animations

	var blendHandle := animator().unusedHandle(&"BlendTransition")
	var autoBlender := animator().autoBlendDriver(blendHandle)

	animator().animationDriver(autoBlender.first.anim).animation = IDLE_DATA.ANIMATION_FULL_NAME
	animator().animationDriver(autoBlender.second.anim).animation = data.ANIMATION_FULL_NAME

	animator().setScale(autoBlender.first.scale, 1.0)
	animator().setScale(autoBlender.second.scale, 1.0)
	animator().setBlendAmount(blendHandle, normRange)

	animator().transitionToUnused(&"BlendTransition", 
		animator().setCoreTransition(&"BlendTransition", data.ANIMATION_FADE_TIME))

	Globals.sfxManager.play(SFXData.Type.stop, player().global_position)

#endregion
