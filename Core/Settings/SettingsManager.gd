extends Node

const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()

enum Language { ENGLISH, CHINESE, SPANISH, FRENCH, GERMAN, ITALIAN, JAPANESE }

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
		"fullscreen": true, 
		"resolution": Vector2i(1920, 1080)
	},
	"audio": {
		"master": 0.8, 
		"music": 0.8, 
		"sfx": 0.8
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
		"Switch weapon": KEY_F,
		"Taunt": KEY_R
	}
}

var Settings : Dictionary = DEFAULT_SETTINGS.duplicate(true)

var isRemapping : bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	print("Settings are Loaded!")
	loadSettings()

func loadSettings():

	var error = config.load(SETTINGS_PATH)
	if error != OK:
		print("No Seettings found!")
		saveSettings()
		return
	
	for section in Settings.keys():
		for key in Settings[section].keys():
			Settings[section][key] = config.get_value(section, key, Settings[section][key])

	applyGame()

func saveSettings():
	print("Setting Settings!")
	for section in Settings.keys():
		for key in Settings[section].keys():
			config.set_value(section, key, Settings[section][key])
	config.save(SETTINGS_PATH)

func applyGame():

	# Apply Language Settins
	var langCodes = ["en", "zh", "es", "fr", "de", "it", "ja"]
	var langID = Settings["game"]["language"]

	if langID >= 0 and langID < langCodes.size():
		var selectedLocale = langCodes[langID]
		TranslationServer.set_locale(selectedLocale)
	else: TranslationServer.set_locale("en")

	# need all the other game settings to do anything