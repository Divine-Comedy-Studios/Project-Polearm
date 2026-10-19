extends Node3D
class_name Effect


#region Signals

signal finished(effect : VFXEffect)

#endregion


#region Enums

enum Type {
	none,
	hitSpark,
	deathBurst,
	landDust,
	dashDust,
	spawnPortal,
}

#endregion


#region Exported variables

@export_group("Flash light")
## Peak energy of the child node "Light" (optional). 0 = no flash.
@export var FLASH_ENERGY : float = 0.0
@export var FLASH_TIME : float = 0.15

@export_group("Timing")
## Added on top of the longest particle lifetime before the effect is handed back to the pool
@export var EXTRA_TIME : float = 0.1

#endregion


#region Member variables

var _particles : Array[GPUParticles3D] = []
var _light : OmniLight3D = null
var _duration : float = 0.0
var _remaining : float = 0.0
var _tween : Tween = null

#endregion


#region Built-in functions

func _ready() -> void:
	for child in get_children():
		if child is GPUParticles3D:
			var particles := child as GPUParticles3D
			_particles.push_back(particles)
			# With explosiveness < 1 the emission is spread over the lifetime, so the last particle dies later
			_duration = maxf(_duration, particles.lifetime * (2.0 - particles.explosiveness) / particles.speed_scale)

	_light = get_node_or_null("Light") as OmniLight3D
	_duration = maxf(_duration, FLASH_TIME) + EXTRA_TIME

	park()


func _process(delta : float) -> void:
	_remaining -= delta
	if _remaining <= 0.0:
		park()
		finished.emit(self)

#endregion


#region Public functions

# intensity 0..1 scales the amount of particles and the brightness of the flash
func play(worldTransform : Transform3D, intensity : float = 1.0) -> void:
	intensity = clampf(intensity, 0.05, 1.0)

	global_transform = worldTransform
	_remaining = _duration
	visible = true
	set_process(true)

	for particles in _particles:
		particles.amount_ratio = intensity
		particles.restart()

	if _light != null and FLASH_ENERGY > 0.0:
		_light.show()
		_light.light_energy = FLASH_ENERGY * intensity

		if _tween != null:
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(_light, "light_energy", 0.0, FLASH_TIME)


func park() -> void:
	set_process(false)
	visible = false

	if _tween != null:
		_tween.kill()
		_tween = null

	for particles in _particles:
		particles.emitting = false

	if _light != null:
		_light.hide()

#endregion
