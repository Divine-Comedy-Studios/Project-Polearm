extends Node
class_name SettingsManager


#region Enums

enum Resolution {
	ultrawide,
	p1080,
	p900,
	p720,
	p540
} 

#endregion


#region Constants

const SETTINGS_PATH : String = "user://settings.cfg"

const DEFAULT_SETTINGS : Dictionary[String, Dictionary] = {
	"game" : {
		"language" : "en", ### @todo why not directly use the string?
		"camera sensitivity" : 1.0,
		"invert y" : false,
		"camera shake" : 1.0,
		"rumble" : 1.0,
	},
	"video" : {
		"window mode" : DisplayServer.WINDOW_MODE_FULLSCREEN, ### @todo why not use the godot enum directly?
		"resolution" : Resolution.p1080,
		"vsync" : true,
		"gamma" : 1.0,
	},
	"audio" : {
		"master" : 1.0, 
		"music" : 1.0, 
		"sfx" : 1.0,
		"mute on focus loss" : true,
	},
	"controller" : { ### @todo remove button type
		"Light attack" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_X},
		"Heavy attack" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_Y},
		"Jump" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_A},
		"Shoot" : {"type" : "axis", "id" : JoyAxis.JOY_AXIS_TRIGGER_LEFT, "direction" : 1}, ### @todo do not count trigger as a axis, unnecceseary
		"Target left" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_LEFT_SHOULDER},
		"Target right" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_RIGHT_SHOULDER},
		"Dodge" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_B},
		"Dash" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_LEFT_STICK},
		"Launcher" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_DPAD_UP},
		"Held target toggle" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_RIGHT_STICK},
		"Switch weapon" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_DPAD_RIGHT},
		"Taunt" : {"type" : "button", "id" : JoyButton.JOY_BUTTON_BACK},
	},
	"keyboard" : {
		"Light attack" : MouseButton.MOUSE_BUTTON_LEFT,
		"Heavy attack" : MouseButton.MOUSE_BUTTON_RIGHT,
		"Jump" : Key.KEY_SPACE,
		"Shoot" : Key.KEY_F,
		"Target left" : Key.KEY_Q,
		"Target right" : Key.KEY_E,
		"Dodge" : Key.KEY_SHIFT,
		"Dash" : Key.KEY_CTRL,
		"Launcher" : Key.KEY_ALT,
		"Held target toggle" : Key.KEY_T,
		"Move left" : Key.KEY_A,
		"Move right" : Key.KEY_D,
		"Move forwards" : Key.KEY_W,
		"Move backwards" : Key.KEY_S,
		"Switch weapon" : Key.KEY_C,
		"Taunt" : Key.KEY_R,
	}
}

const SUPPORTED_LANGUAGES : Array[String] = [
	"en",
	"zh",
	"es",
	"fr",
	"de",
	"it",
	"ja",
]

#endregion


#region Member variables

static var _file : ConfigFile = ConfigFile.new()

static var isRemapping : bool = false ### @todo Part of the overall UI overhaul

#endregion


#region Built-in functions

func _ready() -> void:
	var error := _file.load(SETTINGS_PATH)
	if error != Error.OK:
		_saveDefaultSettings()

		return

#endregion


#region Public functions

static func getSectionNames() -> PackedStringArray:
	return _file.get_sections()

static func getSettingNames(section : String) -> PackedStringArray:
	return _file.get_section_keys(section)


# Get setting values

static func getBool(section : String, key : String) -> bool:
	return _file.get_value(section, key) as bool

static func getInt(section : String, key : String) -> int:
	return _file.get_value(section, key) as int

static func getFloat(section : String, key : String) -> float:
	return _file.get_value(section, key) as float

static func getString(section : String, key : String) -> String:
	return _file.get_value(section, key) as String


static func setBool(section : String, key : String, value : bool) -> void:
	_file.set_value(section, key, value)

static func setInt(section : String, key : String, value : int) -> void:
	_file.set_value(section, key, value)

static func setFloat(section : String, key : String, value : float) -> void:
	_file.set_value(section, key, value)

static func setString(section : String, key : String, value : String) -> void:
	_file.set_value(section, key, value)


### @todo Remove configuring axis in the future
static func getVariant(section : String, key : String) -> Variant:
	return _file.get_value(section, key)

static func setVariant(section : String, key : String, value : Variant) -> void:
	_file.set_value(section, key, value)


# Apply settings

static func applyGameSettings() -> void:
	var langCode := getString("game", "language")

	if SUPPORTED_LANGUAGES.find(langCode) != -1:
		TranslationServer.set_locale(langCode)
	else:
		TranslationServer.set_locale("en")
		setString("game", "language", "en")


static func applyVideoSettings() -> void:
	# Window Mode
	var windowMode := getInt("video", "window mode")

	if windowMode == DisplayServer.WINDOW_FLAG_BORDERLESS:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	else:
		DisplayServer.window_set_mode(windowMode)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

	# VSync
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if getBool("video", "vsync") else DisplayServer.VSYNC_DISABLED)


	### @todo Very unclean, needs urgent fixing

	# Resolution
	# if video["window mode"] == WindowMode.WINDOWED:
	# 	var resIndex = video["resolution"]
	#	var targetRes = Vector2i(1920, 1080)
	#	match resIndex:
	#		Resolution.ultrawide: targetRes = Vector2i(2560, 1080)
	#		Resolution.p1080: targetRes = Vector2i(1920, 1080)
	#		Resolution.p900: targetRes = Vector2i(1600, 900)
	#		Resolution.p720: targetRes = Vector2i(1280, 720)
	#		Resolution.p540: targetRes = Vector2i(960, 540)
	#	get_window().size = targetRes
	#	get_window().move_to_center()

	# Gamma
	# var worldEnv := get_tree().root.find_child("WorldEnvironment", true, false)
	# worldEnv.environment.adjustment_enabled = true
	# worldEnv.environment.adjustment_brightness = video["gamma"]


static func applyAudioSettings() -> void:
	pass


static func applyKeyboardSettings() -> void:
	for actionName : String in _file.get_section_keys("keyboard"):
		var action := getInt("keyboard", actionName)

		var events := InputMap.action_get_events(actionName)
		for event in events:
			if event is InputEventKey or event is InputEventMouseButton:
				InputMap.action_erase_event(actionName, event)

		if action is MouseButton: ### @todo Very confident that this does not work
			var event := InputEventMouseButton.new()
			event.button_index = action as MouseButton
			InputMap.action_add_event(actionName, event)
		else:
			var event := InputEventKey.new()
			event.physical_keycode = action as Key
			InputMap.action_add_event(actionName, event)


static func applyControllerSettings() -> void:
	for actionName : String in _file.get_section_keys("controller"):
		var actionData := getVariant("controller", actionName) as Dictionary

		var events := InputMap.action_get_events(actionName)
		for event in events:
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				InputMap.action_erase_event(actionName, event)
		
		if actionData["type"] == "button":
			var event := InputEventJoypadButton.new()
			event.button_index = actionData["id"]
			InputMap.action_add_event(actionName, event)
		elif actionData["type"] == "axis":
			var event := InputEventJoypadMotion.new()
			event.axis = actionData["id"]
			event.axis_value = actionData["direction"]
			InputMap.action_add_event(actionName, event)


# File saving
static func saveSettings() -> void:
	_file.save(SETTINGS_PATH)

#endregion


#region Private functions

static func _saveDefaultSettings() -> void:
	for sectionName : String in DEFAULT_SETTINGS.keys():
		for settingName : String in DEFAULT_SETTINGS[sectionName].keys():
			_file.set_value(sectionName, settingName, DEFAULT_SETTINGS[sectionName][settingName])

	_file.save(SETTINGS_PATH)

#endregion
