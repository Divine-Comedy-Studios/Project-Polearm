extends Node3D
class_name LedgeStopperBlock


#region Scene members

@export_group("Scene members")
@export var _anchor : Node3D = null
@export var _collider : StaticBody3D = null
@export var _collisionShape : CollisionShape3D = null

#endregion


#region Public functionss

func init(offset : Vector3, offsetYRotation : float, colliderShape : Shape3D, layers : int) -> void:
	rotation.y = offsetYRotation

	_anchor.position = offset
	_collider.collision_layer = layers
	_collisionShape.shape = colliderShape

	disable()


func checkCollision(query : PhysicsRayQueryParameters3D, count : int, scanPercent : float, downwardsLength : float) -> void:
	downwardsLength += _anchor.position.y

	var globalPos := global_position
	var anchorPos := _anchor.global_position
	var rayPos := PPUtil.Math.toFlatVec3(globalPos, anchorPos.y)
	var diff := anchorPos - rayPos

	rayPos += diff * (1 - scanPercent)
	var dist := (diff * scanPercent) / (count)

	for i in range(count):
		query.from = rayPos
		query.to = query.from
		query.to.y -= downwardsLength

		var queryResult := get_world_3d().direct_space_state.intersect_ray(query)
		if queryResult.is_empty():
			if !enabled():
				enable(rayPos)

			return
		elif enabled():
			disable()

			return

		rayPos += dist
		rayPos.y += queryResult.position.y - globalPos.y


func enable(pos : Vector3) -> void:
	_collider.process_mode = Node.PROCESS_MODE_INHERIT

	#_collider.rotation.y = _collider.global_rotation.y
	#_collider.position = _collider.global_position
	_collider.top_level = true
	_collider.position = pos

func disable() -> void:
	_collider.process_mode = Node.PROCESS_MODE_DISABLED

	_collider.top_level = false
	_collider.rotation.y = 0.0
	_collider.position = Vector3.ZERO


func enabled() -> bool:
	return _collider.top_level

#endregion
