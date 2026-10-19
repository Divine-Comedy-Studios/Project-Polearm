extends Node3D

# Standalone audio test. Run this scene (F6) and use the keys:
#	M menu music   G game music   P pause / unpause   S stop music   B pause behavior (silence <-> track)
#	1 click (2D)   2 hit   3 swing   4 footstep   5 land   6 door on   7 door off   8 death
# The 3D sounds come from three markers: Q = left, W = middle, E = right (hold the number keys after pressing).
# Left/right panning and distance are measured from the camera.


@export var _audio : AudioManager = null
@export var _sfx : SFXManager = null
@export var _label : Label = null

var _paused : bool = false
var _spot : Vector3 = Vector3(0.0, 1.0, -4.0)

const SPOTS := { KEY_Q: Vector3(-8.0, 1.0, -4.0), KEY_W: Vector3(0.0, 1.0, -4.0), KEY_E: Vector3(8.0, 1.0, -4.0) }


func _unhandled_input(event : InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	var key := (event as InputEventKey).keycode
	if SPOTS.has(key):
		_spot = SPOTS[key]
		_refresh()
		return

	match key:
		KEY_M: _audio.playMusic(Audio.MusicType.menu)
		KEY_G: _audio.playMusic(Audio.MusicType.game)
		KEY_S: _audio.stopMusic()
		KEY_P:
			_paused = not _paused
			if _paused: _audio.enterPause()
			else: _audio.exitPause()
		KEY_B:
			_audio.PAUSE_BEHAVIOR = AudioManager.PauseBehavior.track if _audio.PAUSE_BEHAVIOR == AudioManager.PauseBehavior.silence else AudioManager.PauseBehavior.silence
		KEY_1: _audio.playSfx2D(Audio.SfxType.uiClick)
		KEY_2: _sfx.play(Audio.SfxType.hit, _spot)
		KEY_3: _sfx.play(Audio.SfxType.swing, _spot)
		KEY_4: _sfx.play(Audio.SfxType.footstep, _spot)
		KEY_5: _sfx.play(Audio.SfxType.land, _spot)
		KEY_6: _sfx.play(Audio.SfxType.doorOn, _spot)
		KEY_7: _sfx.play(Audio.SfxType.doorOff, _spot)
		KEY_8: _sfx.play(Audio.SfxType.death, _spot)

	_refresh()


func _ready() -> void:
	assert(_audio != null and _sfx != null and _label != null, "AudioTest._ready(): Please assign the members!")
	_refresh()


func _refresh() -> void:
	_label.text = "M menu   G game   S stop   P pause (%s)   B pause behavior: %s\n1 click (2D)   2 hit   3 swing   4 footstep   5 land   6 door on   7 door off   8 death\nQ / W / E: sound position left / middle / right (now x = %.0f)\nmusic: %s" % [
		"paused" if _paused else "running",
		AudioManager.PauseBehavior.keys()[_audio.PAUSE_BEHAVIOR],
		_spot.x,
		Audio.MusicType.keys()[_audio.currentMusic()]]
