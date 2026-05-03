class_name SaveUtility


#region Constants

const SAVE_DATA_BASE_PATH : String = "user://saves/save_"
const EXTENSION : String = ".dat"

#endregion


#region Public funcitons

func hasSave(slot : int) -> bool:
	var path := _getPath(slot) as String
	return path != ""

func loadSave(slot : int) -> Dictionary:
	var path := _getPath(slot) as String

	if path == "":
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Failed to open binary file for reading: " + error_string(FileAccess.get_open_error()))
		return {}

	var content = file.get_var()
	if content is Dictionary:
		return content
		
	return {}

func writeSave(data : Dictionary, slot : int) -> void:
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")
		
	var path = SAVE_DATA_BASE_PATH + str(slot) + "." + EXTENSION
	var file := FileAccess.open(path, FileAccess.WRITE)
	
	if file == null:
		push_error("SaveManager: Failed to open binary file for writing: " + error_string(FileAccess.get_open_error()))
		return
		
	file.store_var(data)
	
func clearSave(slot : int) -> void:
	var path := _getPath(slot) as String

	if path != "":
		var dir = DirAccess.open("user://saves")
		if dir:
			dir.remove(path.get_file())

#endregion


#region Private functions

func _getPath(slot: int) -> String:
	var dir = DirAccess.open("user://")

	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")
		
	var path = SAVE_DATA_BASE_PATH + str(slot) + "." + EXTENSION

	if not FileAccess.file_exists(path):
		return ""
		
	return path
	
#endregion
