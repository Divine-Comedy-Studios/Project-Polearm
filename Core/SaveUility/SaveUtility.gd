class_name SaveUtility


#region Enums

enum SaveFileVersion {
	invalid = 0,
	v0_0_1 = 1,
}

#endregion


#region Constants

# Metadata

const SAVE_FILE_BASE_PATH : String = "user://saves/save_%s.dat"
const SAVE_FILE_VERSION : int = SaveFileVersion.v0_0_1


# Save file & debug

const DEBUG_TEMP_SAVE : int = -1

const EMPTY_SAVE : Dictionary = {
	"version" : SAVE_FILE_VERSION,
}
const DEBUG_SAVE : Dictionary = {
	"version" : SaveFileVersion.invalid
}

#endregion


#region Public funcitons

static func hasSave(slot : int) -> bool:
	return _getAndVerifyPath(slot) != ""


static func loadSave(slot : int) -> Dictionary:
	if slot == -1:
		return DEBUG_SAVE.duplicate_deep()

	var path := _getAndVerifyPath(slot)
	if path.is_empty():
		return EMPTY_SAVE.duplicate_deep()

	# Having a bad file should send you to a special menu

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager.loadSave(): Failed to open binary file for reading: " + error_string(FileAccess.get_open_error()))
		return { }

	var content = file.get_var()
	if not (content is Dictionary):
		return { }

	if not _verifyIntegrity(content):
		return { }

	return content as Dictionary


static func writeSave(data : Dictionary, slot : int) -> bool:
	if not _verifyIntegrity(data):
		return false
		
	var path := SAVE_FILE_BASE_PATH.format(str(slot))
	var file := FileAccess.open(path, FileAccess.WRITE)
	
	if file == null:
		push_error("SaveManager.writeSave(): Failed to open binary file for writing: " + error_string(FileAccess.get_open_error()))
		return false

	return file.store_var(data)
	
static func clearSave(slot : int) -> void:
	var path := _getAndVerifyPath(slot) as String

	if not path.is_empty():
		DirAccess.remove_absolute(path)

#endregion


#region Private functions

static func _getAndVerifyPath(slot: int) -> String:
	var path := SAVE_FILE_BASE_PATH.format(str(slot))

	if not FileAccess.file_exists(path):
		return String()
		
	return path


static func _verifyIntegrity(data: Dictionary) -> bool:
	if (
		not data.has("version") or 
		data["version"] != SAVE_FILE_VERSION
	):
		push_error("SaveManager._verifyIntegrity(): Save file integrity check failed!")
		return false
	
	return true

#endregion
