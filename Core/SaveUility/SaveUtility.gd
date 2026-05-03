class_name SaveUtility


#region Enum

enum DEBUG_SaveFiles {
  gym = 0x1FFFFFFF,
  museum = 0x1FFFFFFF,
  zoo = 0x2FFFFFFF,
}

#endregion


#region Constants

const SAVE_DATA_BASE_PATH : String = "user://saves/save_"
const EXTENSION : String = ".dat"
const SAVE_VERSION : int = 1

const EMPTY_SAVE : Dictionary = {
	"version" : 1,
}

#endregion


#region Public funcitons

static func hasSave(slot : int) -> bool:
	var path := _getPath(slot) as String
	return path != ""

static func loadSave(slot : int) -> Dictionary:
	var path := _getPath(slot) as String

	if path == "":
		return EMPTY_SAVE.duplicate(true)

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Failed to open binary file for reading: " + error_string(FileAccess.get_open_error()))
		return {}

	var content = file.get_var()
	if not (content is Dictionary):
		return {}

	if _verifyVersion(content):
		return content

	return {}

static func writeSave(data : Dictionary, slot : int) -> void:
	if not _verifyVersion(data):
		return

	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")
		
	var path = SAVE_DATA_BASE_PATH + str(slot) + "." + EXTENSION
	var file := FileAccess.open(path, FileAccess.WRITE)
	
	if file == null:
		push_error("SaveManager: Failed to open binary file for writing: " + error_string(FileAccess.get_open_error()))
		return
		
	file.store_var(data)
	
static func clearSave(slot : int) -> void:
	var path := _getPath(slot) as String

	if path != "":
		var dir = DirAccess.open("user://saves")
		if dir:
			dir.remove(path.get_file())

#endregion


#region Private functions

static func _getPath(slot: int) -> String:
	var dir = DirAccess.open("user://")

	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")
		
	var path = SAVE_DATA_BASE_PATH + str(slot) + "." + EXTENSION

	if not FileAccess.file_exists(path):
		return ""
		
	return path
	
static func _verifyVersion(data: Dictionary) -> bool:
	if not data.has("version") or data["version"] != SAVE_VERSION:
		push_error("SaveManager: Failed to write - missing or incorrect save version.")
		return false
	
	return true

#endregion
