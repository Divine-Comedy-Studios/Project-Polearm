extends Node
class_name SettingsManager


#region Enums

enum WindowMode {
	windowed,
	fullscreen,
	borderless,
}

enum Resolution {
	ultrawide,
	p1080,
	p900,
	p720
}

enum InputType {
	keyboard,
	mouse,
	controller,
	controllerButton = controller,
	controllerAxis
}


enum TargetMode { ### @todo
	leftStick,
	bumper,
	trigger,
	dPad,
}


enum SettingVersion {
	invalid = 0,
	v0_0_1 = 1,
}

#endregion


#region Constants

const TRIGGER_SENSITIVITY : float = 0.5

const SETTINGS_PATH : String = "user://settings.cfg"
const SETTINGS_VERSION : int = SettingVersion.v0_0_1


const DEFAULT_SETTINGS : Dictionary[String, Dictionary] = {
	"metadata" : {
		"version" : SETTINGS_VERSION,
		"lastSave" : -1,
	},
	"game" : {
		"language" : "en", ### @todo why not directly use the string?
		"camera sensitivity" : 1.0,
		"invert y" : false,
		"camera shake" : 1.0,
		"rumble" : 1.0,
	},
	"video" : {
		"window mode" : DisplayServer.WINDOW_MODE_FULLSCREEN,
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
	"controller" : {
		"Light attack" : {
			"type" : InputType.controllerButton,
			"id" : JoyButton.JOY_BUTTON_X
		},
		"Heavy attack" : {
			"type" : InputType.controllerButton,
			"id" : JoyButton.JOY_BUTTON_Y
		},
		"Jump" : {
			"type" : InputType.controllerButton,
			"id" : JoyButton.JOY_BUTTON_A
		},
		"Dash" : {
			"type" : InputType.controllerButton,
			"id" : JoyButton.JOY_BUTTON_RIGHT_SHOULDER
		},
		"Heal" : {
			"type" : InputType.controllerButton,
			"id" : JoyButton.JOY_BUTTON_DPAD_UP
		},
		"Held target toggle" : {
			"type" : InputType.controllerButton,
			"id" : JoyButton.JOY_BUTTON_RIGHT_STICK
		},
		"Switch weapon" : {
			"type" : InputType.controllerButton,
			"id" : JoyButton.JOY_BUTTON_DPAD_RIGHT
		},
		"Taunt" : {
			"type" : InputType.controllerButton,
			"id" : JoyButton.JOY_BUTTON_BACK
		},
	},
	"keyboard" : {
		"Light attack" : {
			"type" : InputType.mouse,
			"id" : MouseButton.MOUSE_BUTTON_LEFT,
		},
		"Heavy attack" : {
			"type" : InputType.mouse,
			"id" : MouseButton.MOUSE_BUTTON_RIGHT,
		},
		"Jump" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_SPACE,
		},
		"Target left" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_Q,
		},
		"Target right" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_E,
		},
		"Dash" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_SHIFT,
		},
		"Heal" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_Q,
		},
		"Held target toggle" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_T,
		},
		"Move left" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_A,
		},
		"Move right" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_D,
		},
		"Move forwards" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_W,
		},
		"Move backwards" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_S,
		},
		"Switch weapon" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_C,
		},
		"Taunt" : {
			"type" : InputType.keyboard,
			"id" : Key.KEY_R
		},
	},
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

var _file : ConfigFile = ConfigFile.new()

#endregion


#region Built-in functions

func _ready() -> void:
	if Globals.settingsManager != null:
		push_error("SettingsManager._ready(): SettingsManager has already been initialized once!")

		return

	Globals.settingsManager = self

	var error := _file.load(SETTINGS_PATH)
	_verifySettings()

	applyGameSettings()
	applyVideoSettings()
	applyAudioSettings()
	applyKeyboardSettings()
	applyControllerSettings()

#endregion


#region Public functions

func getSectionNames() -> PackedStringArray:
	return _file.get_sections()

func getSettingNames(section : String) -> PackedStringArray:
	return _file.get_section_keys(section)


# Get setting values

func getBool(section : String, key : String) -> bool:
	return _file.get_value(section, key) as bool

func getInt(section : String, key : String) -> int:
	return _file.get_value(section, key) as int

func getFloat(section : String, key : String) -> float:
	return _file.get_value(section, key) as float

func getString(section : String, key : String) -> String:
	return _file.get_value(section, key) as String


func setBool(section : String, key : String, value : bool) -> void:
	_file.set_value(section, key, value)

func setInt(section : String, key : String, value : int) -> void:
	_file.set_value(section, key, value)

func setFloat(section : String, key : String, value : float) -> void:
	_file.set_value(section, key, value)

func setString(section : String, key : String, value : String) -> void:
	_file.set_value(section, key, value)


### @todo Remove configuring axis in the future
func getVariant(section : String, key : String) -> Variant:
	return _file.get_value(section, key)

func setVariant(section : String, key : String, value : Variant) -> void:
	_file.set_value(section, key, value)


# Apply settings

func applyGameSettings() -> void:
	var langCode := getString("game", "language")

	if SUPPORTED_LANGUAGES.find(langCode) != -1:
		TranslationServer.set_locale(langCode)
	else:
		TranslationServer.set_locale("en")
		setString("game", "language", "en")


func applyVideoSettings() -> void:
	# Window Mode
	match getInt("video", "window mode"):
		WindowMode.windowed:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

			match getInt("video", "resolution"):
				Resolution.ultrawide:
					get_window().size = Vector2i(2560, 1080)
				Resolution.p1080:
					get_window().size = Vector2i(1920, 1080)
				Resolution.p900:
					get_window().size = Vector2i(1600, 900)
				Resolution.p720:
					get_window().size = Vector2i(1280, 720)

			get_window().move_to_center()

		WindowMode.fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		WindowMode.borderless:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

	# VSync
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if getBool("video", "vsync") else DisplayServer.VSYNC_DISABLED)

	# Gamma

	if Globals.visuals == null:
		push_error("SettingsManager.applyVideoSettings(): Global visuals not assigned!")

		return

	var worldEnv := Globals.visuals.environment
	worldEnv.environment.adjustment_enabled = true
	worldEnv.environment.adjustment_brightness = getFloat("video", "gamma")


func applyAudioSettings() -> void:
	if Globals.audioManager == null:
		push_error("SettingsManager.applyAudioSettings(): Global audio manager not assigned!")

	Globals.audioManager.setBusVolume(AudioManager.MASTER_BUS, getFloat("audio", "master"))
	Globals.audioManager.setBusVolume(AudioManager.MUSIC_BUS, getFloat("audio", "music"))
	Globals.audioManager.setBusVolume(AudioManager.SFX_BUS, getFloat("audio", "sfx"))

	Globals.audioManager.muteOnFocusLost = getBool("audio", "mute on focus loss")


func applyKeyboardSettings() -> void:
	for actionName : String in _file.get_section_keys("keyboard"):
		var actionData := getVariant("keyboard", actionName) as Dictionary

		var events := InputMap.action_get_events(actionName)
		for event in events:
			if event is InputEventKey or event is InputEventMouseButton:
				InputMap.action_erase_event(actionName, event)

		if actionData["type"] == InputType.mouse:
			var event := InputEventMouseButton.new()
			event.button_index = actionData["id"] as MouseButton
			InputMap.action_add_event(actionName, event)
		elif actionData["type"] == InputType.keyboard:
			var event := InputEventKey.new()
			event.physical_keycode = actionData["id"] as Key
			InputMap.action_add_event(actionName, event)


func applyControllerSettings() -> void:
	for actionName : String in _file.get_section_keys("controller"):
		var actionData := getVariant("controller", actionName) as Dictionary

		var events := InputMap.action_get_events(actionName)
		for event in events:
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				InputMap.action_erase_event(actionName, event)
		
		if actionData["type"] == InputType.controllerButton:
			var event := InputEventJoypadButton.new()
			event.button_index = actionData["id"]
			InputMap.action_add_event(actionName, event)
		elif actionData["type"] == InputType.controllerAxis:
			var event := InputEventJoypadMotion.new()
			event.axis = actionData["id"]
			event.axis_value = TRIGGER_SENSITIVITY
			InputMap.action_add_event(actionName, event)


func saveSectionDefault(sectionName : String) -> void:
	for settingName : String in DEFAULT_SETTINGS[sectionName].keys():
			_file.set_value(sectionName, settingName, DEFAULT_SETTINGS[sectionName][settingName])


# File saving
func saveSettings() -> void:
	_file.save(SETTINGS_PATH)

#endregion


#region Private functions

func _saveDefaultSettings() -> void:
	for sectionName : String in DEFAULT_SETTINGS.keys():
		saveSectionDefault(sectionName)

	_file.save(SETTINGS_PATH)


func _verifySettings() -> void:
	var needsSave := false
	
	for section in DEFAULT_SETTINGS.keys():
		for key in DEFAULT_SETTINGS[section].keys():
			var defaultValue = DEFAULT_SETTINGS[section][key]

			if not _file.has_section_key(section, key): # Check if the loaded file is missing this specific setting
				_file.set_value(section, key, defaultValue)
				needsSave = true
			else:
				var value = _file.get_value(section, key)

				if not typeof(defaultValue) == typeof(value):
					_file.set_value(section, key, defaultValue)
					needsSave = true
				elif section == "metadata" and key == "version":
					var currentVersion := value as int
					if currentVersion != SETTINGS_VERSION:
						_processDeprecatedSettings(currentVersion)
						return

	# If we found missing pieces and added them, save the updated file
	if needsSave:
		_file.save(SETTINGS_PATH)


func _processDeprecatedSettings(version : int) -> void:
	_saveDefaultSettings() ### @todo Implement a proper version of saving deprecated versions

	_file.save(SETTINGS_PATH)

#endregion
