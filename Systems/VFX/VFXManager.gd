extends Node
class_name VFXManager

# Plays one-shot effects at a point in the world:
#	Globals.world.vfxManager.play(VFX.Type.hitSpark, position, normal)
# Effects are pooled per type, nothing is instantiated while playing once the pool is warm.


#region Exported variables

@export_group("VFX config")
@export var VFX_DATASET : VFXDataset = null

#endregion


#region Types

class PoolData extends RefCounted:
	var scene : PackedScene = null
	var maxSize : int = 0
	var free : Array[VFXEffect] = []
	var active : Array[VFXEffect] = [] # Oldest first

#endregion


#region Member variables

var _pools : Dictionary[VFX.Type, PoolData] = {}

#endregion


#region Built-in functions

func _ready() -> void:
	assert(VFX_DATASET != null, "VFXManager._ready(): VFX dataset not assigned!")

	for type in VFX_DATASET.DATASET:
		_createPool(type, VFX_DATASET.DATASET[type])

#endregion


#region Public functions

# normal is the direction the effect points to (+Y of the effect scene), e.g. the surface normal at a hit.
# intensity 0..1 scales amount and brightness.
func play(type : VFX.Type, position : Vector3, normal : Vector3 = Vector3.UP, intensity : float = 1.0) -> void:
	var pool := _pools.get(type) as PoolData
	if pool == null:
		push_error("VFXManager.play(): No effect registered for type %s!" % VFX.Type.keys()[type])
		return

	var effect := _acquire(pool)
	effect.play(Transform3D(_basisFromNormal(normal), position), intensity)


# Stops everything immediately, e.g. when a stage is reset
func clear() -> void:
	for pool : PoolData in _pools.values():
		for effect in pool.active:
			effect.park()
			pool.free.push_back(effect)
		pool.active.clear()

#endregion


#region Private functions

func _createPool(type : VFX.Type, data : VFXData) -> void:
	assert(data != null, "VFXManager._createPool(): Data for %s is null!" % VFX.Type.keys()[type])

	var pool := PoolData.new()
	pool.scene = load(data.SCENE_PATH) as PackedScene
	assert(pool.scene != null, "VFXManager._createPool(): Could not load '%s'!" % data.SCENE_PATH)
	pool.maxSize = data.MAX_INSTANCES

	for i in mini(data.PREWARM, data.MAX_INSTANCES):
		pool.free.push_back(_instantiate(pool))

	_pools[type] = pool


func _instantiate(pool : PoolData) -> VFXEffect:
	var effect := pool.scene.instantiate() as VFXEffect
	assert(effect != null, "VFXManager._instantiate(): Effect root must use VFXEffect.gd!")

	add_child(effect)
	effect.finished.connect(_onEffectFinished.bind(pool))
	return effect


func _acquire(pool : PoolData) -> VFXEffect:
	var effect : VFXEffect = null

	if not pool.free.is_empty():
		effect = pool.free.pop_back()
	elif pool.active.size() < pool.maxSize:
		effect = _instantiate(pool)
	else:
		effect = pool.active.pop_front() # Reuse the oldest one
		effect.park()

	pool.active.push_back(effect)
	return effect


func _basisFromNormal(normal : Vector3) -> Basis:
	if normal.is_zero_approx():
		return Basis.IDENTITY

	var direction := normal.normalized()
	if direction.dot(Vector3.UP) < -0.999:
		return Basis(Vector3.RIGHT, PI)

	return Basis(Quaternion(Vector3.UP, direction))

#endregion


#region Signal functions

func _onEffectFinished(effect : VFXEffect, pool : PoolData) -> void:
	pool.active.erase(effect)
	pool.free.push_back(effect)

#endregion
