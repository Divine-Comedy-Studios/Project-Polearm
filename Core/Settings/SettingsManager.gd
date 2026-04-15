extends Node

const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()

enum Language { ENGLISH, CHINESE, SPANISH, FRENCH, GERMAN, ITALIAN, JAPANESE }

enum WindowMode { WINDOWED, FULL_SCREEN, BORDERLESS }

enum Resolution { ULTRAWIDE, RES_1080P, RES_900P, RES_720P, RES_540P }

# Default values
const DEFAULT_SETTINGS : Dictionary[String, Dictionary] = {
	"game": {
        "language": Language.ENGLISH,
		"camera sensitivity": 1.0,
		"invert y": false,
		"camera shake": 1.0,
		"rumble": 1.0
	},
	"video": {
		"window mode": WindowMode.BORDERLESS, 
		"resolution": Resolution.RES_1080P,
		"vsync": true,
		"gamma": 1.0
	},
	"audio": {
		"master": 1.0, 
		"music": 1.0, 
		"sfx": 1.0,
		"mute on focus loss": true
	},
	"controller": {
		"Light attack": {"type": "button", "id": JOY_BUTTON_X},
		"Heavy attack": {"type": "button", "id": JOY_BUTTON_Y},
		"Jump": {"type": "button", "id": JOY_BUTTON_A},
		"Shoot": {"type": "axis", "id": JOY_AXIS_TRIGGER_LEFT, "direction": 1},
		"Target left": {"type": "button", "id": JOY_BUTTON_LEFT_SHOULDER},
		"Target right": {"type": "button", "id": JOY_BUTTON_RIGHT_SHOULDER},
		"Dodge": {"type": "button", "id": JOY_BUTTON_B},
		"Sprint": {"type": "button", "id": JOY_BUTTON_LEFT_STICK},
		"Launcher": {"type": "button", "id": JOY_BUTTON_DPAD_UP},
		"Held target toggle": {"type": "button", "id": JOY_BUTTON_RIGHT_STICK},
		"Switch weapon": {"type": "button", "id": JOY_BUTTON_DPAD_RIGHT},
		"Taunt": {"type": "button", "id": JOY_BUTTON_BACK}
	},
	"keyboard": {
		"Light attack": MOUSE_BUTTON_LEFT,
		"Heavy attack": MOUSE_BUTTON_RIGHT,
		"Jump": KEY_SPACE,
		"Shoot": KEY_F,
		"Target left": KEY_Q,
		"Target right": KEY_E,
		"Dodge": KEY_SHIFT,
		"Sprint": KEY_CTRL,
		"Launcher": KEY_ALT,
		"Held target toggle": KEY_T,
		"Move left": KEY_A,
		"Move right": KEY_D,
		"Move forwards": KEY_W,
		"Move backwards": KEY_S,
		"Switch weapon": KEY_C,
		"Taunt": KEY_R
	}
}

var Settings : Dictionary = DEFAULT_SETTINGS.duplicate(true)

var isRemapping : bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	print("Settings are Loaded!")
	loadSettings()

func loadSettings() -> void:

	var error = config.load(SETTINGS_PATH)
	if error != OK:
		print("No Seettings found!")
		saveSettings()
		return
	
	for section in Settings.keys():
		for key in Settings[section].keys():
			Settings[section][key] = config.get_value(section, key, Settings[section][key])

	applyGame()
	applyVideo()
	applyAudio()
	applyController()
	applyKeyboard()

func saveSettings() -> void:
	print("Setting Settings!")
	for section in Settings.keys():
		for key in Settings[section].keys():
			config.set_value(section, key, Settings[section][key])
	config.save(SETTINGS_PATH)

func applyGame() -> void:

	# Apply Language Settins
	var langCodes = ["en", "zh", "es", "fr", "de", "it", "ja"]
	var langID = Settings["game"]["language"]

	if langID >= 0 and langID < langCodes.size():
		var selectedLocale = langCodes[langID]
		TranslationServer.set_locale(selectedLocale)
	else: TranslationServer.set_locale("en")

func applyVideo() -> void:
	var video = Settings["video"]

	# Window Mode
	match video["window mode"]:
		WindowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		WindowMode.FULL_SCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		WindowMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

	# Resolution
	if video["window mode"] == WindowMode.WINDOWED:
		var resIndex = video["resolution"]
		var targetRes = Vector2i(1920, 1080)
		match resIndex:
			Resolution.ULTRAWIDE: targetRes = Vector2i(2560, 1080)
			Resolution.RES_1080P: targetRes = Vector2i(1920, 1080)
			Resolution.RES_900P: targetRes = Vector2i(1600, 900)
			Resolution.RES_720P: targetRes = Vector2i(1280, 720)
			Resolution.RES_540P: targetRes = Vector2i(960, 540)
		get_window().size = targetRes
		get_window().move_to_center()

	# VSync
	var vsyncState = DisplayServer.VSYNC_ENABLED if video["vsync"] else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsyncState)

	# Gamma
	var worldEnv = get_tree().root.find_child("WorldEnvironment", true, false)
	if worldEnv and worldEnv.environment:
		worldEnv.environment.adjustment_enabled = true
		worldEnv.environment.adjustment_brightness = video["gamma"]
		
func applyAudio() -> void:
	pass

func applyController() -> void:
	for action in Settings["controller"].keys():
		var data = Settings["controller"][action]

		var events = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				InputMap.action_erase_event(action, event)
		
		if data["type"] == "button":
			var newEvent = InputEventJoypadButton.new()
			newEvent.button_index = data["id"]
			InputMap.action_add_event(action, newEvent)
		elif data["type"] == "axis":
			var newEvent = InputEventJoypadMotion.new()
			newEvent.axis = data["id"]
			newEvent.axis_value = data["direction"]
			InputMap.action_add_event(action, newEvent)

func applyKeyboard() -> void:
	for action in Settings["keyboard"].keys():
		var keyCode = Settings["keyboard"][action]

		var events = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventKey or event is InputEventMouseButton:
				InputMap.action_erase_event(action, event)
		
		if keyCode is MouseButton:
			var newEvent = InputEventMouseButton.new()
			newEvent.button_index = keyCode
			InputMap.action_add_event(action, newEvent)
		else:
			var newEvent = InputEventKey.new()
			newEvent.physical_keycode = keyCode
			InputMap.action_add_event(action, newEvent)
