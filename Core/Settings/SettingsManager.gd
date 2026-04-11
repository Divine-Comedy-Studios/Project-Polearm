extends Node

const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()

# Default values
var Settings : Dictionary[String, Dictionary] = {
	"game": {
        "language": "English"
		
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
		"Light attack": JOY_BUTTON_X,
		"Heavy attack": JOY_BUTTON_Y,
		"Jump": JOY_BUTTON_A,
		"Shoot": JOY_AXIS_TRIGGER_LEFT,
		"Target left": JOY_BUTTON_LEFT_SHOULDER,
		"Target right": JOY_BUTTON_RIGHT_SHOULDER,
		"Dodge": JOY_BUTTON_B,
		"Sprint": JOY_BUTTON_LEFT_STICK,
		"Launcher": JOY_BUTTON_DPAD_UP,
		"Held target toggle": JOY_BUTTON_RIGHT_STICK,
		"Switch weapon": JOY_BUTTON_DPAD_RIGHT,
		"Taunt": JOY_BUTTON_BACK
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
		"Taunt": KEY_R
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	loadSettings()

func loadSettings():
	pass