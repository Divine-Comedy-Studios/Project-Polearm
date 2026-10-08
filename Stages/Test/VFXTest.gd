extends Node3D

# Standalone preview of every effect. Run this scene (F6) and press the number keys.
#	1 hit spark   2 death burst   3 land dust   4 dash dust   5 spawn portal   Space: everything at once


#region Scene members

@export var _vfx : VFXManager = null
@export var _camera : Camera3D = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(_vfx != null, "VFXTest._ready(): VFXManager not assigned!")
	assert(_camera != null, "VFXTest._ready(): Camera not assigned!")

	_camera.look_at(Vector3(0.0, 1.0, 0.0))


func _unhandled_input(event : InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	match (event as InputEventKey).keycode:
		KEY_1: _playHitSpark(Vector3.ZERO)
		KEY_2: _playDeathBurst(Vector3.ZERO)
		KEY_3: _playLandDust(Vector3.ZERO)
		KEY_4: _playDashDust(Vector3.ZERO)
		KEY_5: _playSpawnPortal(Vector3.ZERO)
		KEY_SPACE:
			_playHitSpark(Vector3(-3.0, 0.0, 0.0))
			_playDeathBurst(Vector3(-1.5, 0.0, 0.0))
			_playLandDust(Vector3(0.0, 0.0, 0.0))
			_playDashDust(Vector3(1.5, 0.0, 0.0))
			_playSpawnPortal(Vector3(3.0, 0.0, 0.0))

#endregion


#region Private functions

func _playHitSpark(origin : Vector3) -> void:
	# Pretend the hit is on a wall facing the camera
	_vfx.play(VFX.Type.hitSpark, origin + Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.2, 1.0))

func _playDeathBurst(origin : Vector3) -> void:
	_vfx.play(VFX.Type.deathBurst, origin + Vector3(0.0, 0.8, 0.0))

func _playLandDust(origin : Vector3) -> void:
	_vfx.play(VFX.Type.landDust, origin)

func _playDashDust(origin : Vector3) -> void:
	# Dash to the right, so the dust is kicked to the left
	_vfx.play(VFX.Type.dashDust, origin + Vector3(0.0, 0.1, 0.0), Vector3(-1.0, 0.15, 0.0))

func _playSpawnPortal(origin : Vector3) -> void:
	_vfx.play(VFX.Type.spawnPortal, origin)

#endregion
