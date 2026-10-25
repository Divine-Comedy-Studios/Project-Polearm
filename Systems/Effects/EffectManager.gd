extends Node
class_name VFXManager

# Plays one-shot effects at a point in the world:
#	Globals.vfxManager.play(VFX.Type.hitSpark, position, normal)
#
# This is a layer above the GameObjectManager. The effects are game objects, which the GameObjectManager pools and spawns,
# so this has no pools of its own. All it adds is the API for effects, and a limit for how many effects of a type play at once.
#
# Setup: every VFX.Type needs an entry in the GameObjectDataset, with the effect scene (its root uses VFXEffect.gd),
# VFXHandle.gd as the handle script and PREINITIALIZE as the amount to create up front.


#region Helper classes

# Spawn data of the VFXHandle
class Payload extends RefCounted:
	var manager : VFXManager = null
	var type : VFX.Type = VFX.Type.none
	var transform : Transform3D = Transform3D.IDENTITY
	var intensity : float = 1.0

#endregion


#region Exported variables

@export_group("VFX config")
## How many effects of one type may play at the same time. If it is exceeded, the oldest one is cut off. 0 = no limit.
@export var MAX_INSTANCES : int = 8
## Limits for single types, instead of MAX_INSTANCES.
@export var MAX_INSTANCES_OVERRIDES : Dictionary[VFX.Type, int] = { }

#endregion


#region Member variables

var _active : Array[VFXHandle] = [ ] # Oldest first

#endregion


#region Built-in functions

func _ready() -> void:
	if Globals.vfxManager != null:
		push_error("VFXManager._ready(): VFX manager has already been initialized once!")
		return

	Globals.vfxManager = self

#endregion


#region Public functions

# normal is the direction the effect points to (+Y of the effect scene), e.g. the surface normal at a hit.
# intensity 0..1 scales amount and brightness.
func play(type : VFX.Type, position : Vector3, normal : Vector3 = Vector3.UP, intensity : float = 1.0) -> void:
	assert(type != VFX.Type.none, "VFXManager.play(): Can't play an effect of type none!")

	_makeRoom(type)

	var payload := Payload.new()
	payload.manager = self
	payload.type = type
	payload.transform = Transform3D(_basisFromNormal(normal), position)
	payload.intensity = intensity

	Globals.gameObjectManager.spawn(type as GameObject.Type, payload)


# Stops all effects immediately, e.g. when a stage is reset. Resetting the GameObjectManager does this as well.
func clear() -> void:
	for handle : VFXHandle in _active.duplicate():
		handle.stop()


# Called by the handles
func register(handle : VFXHandle) -> void:
	_active.push_back(handle)

func unregister(handle : VFXHandle) -> void:
	_active.erase(handle)

#endregion


#region Private functions

# If the limit of the type is reached, the oldest effect of the type is cut off so that its object can be used again
func _makeRoom(type : VFX.Type) -> void:
	var limit : int = MAX_INSTANCES_OVERRIDES.get(type, MAX_INSTANCES)
	if limit <= 0:
		return

	var count := 0
	var oldest : VFXHandle = null
	for handle : VFXHandle in _active:
		if handle.type != type:
			continue

		count += 1
		if oldest == null:
			oldest = handle

	if count >= limit:
		oldest.stop()


func _basisFromNormal(normal : Vector3) -> Basis:
	if normal.is_zero_approx():
		return Basis.IDENTITY

	var direction := normal.normalized()
	if direction.dot(Vector3.UP) < -0.999:
		return Basis(Vector3.RIGHT, PI)

	return Basis(Quaternion(Vector3.UP, direction))

#endregion
