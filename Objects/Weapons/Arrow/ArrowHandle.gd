extends GameObject
class_name ArrowHandle

# Handle for the Arrow, set as HANDLE_SCRIPT_PATH in the GameObjectDataset.


#region Override functions

func _initImpl() -> void:
	assert(object is Arrow, "ArrowHandle._initImpl(): Object must be an Arrow!")

	(object as Arrow).handle = self


func spawn(payload : Variant) -> void:
	assert(payload is ArrowPhysics, "ArrowHandle.spawn(): Wrong payload type!")

	(object as Arrow).spawn(payload as ArrowPhysics)

#endregion
