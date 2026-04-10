extends Node

const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()

# Default values
var Settings : Dictionary = {
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
		"Light attack": null,
		"Heavy attack": null,
		"Jump": null,
		"Shoot": JOY_BUTTON_B,
		"Target left": null,
		"Target right": null,
		"Dodge": null,
		"Sprint": null,
		"Launcher": null,
		"Held target toggle": null,
		"Switch weapon": null,
		"Taunt": null
	},
	"keyboard": {
		"Light attack": null,
		"Heavy attack": null,
		"Jump": null,
		"Shoot": null,
		"Target left": null,
		"Target right": null,
		"Dodge": null,
		"Sprint": null,
		"Launcher": null,
		"Held target toggle": null,
		"Move left": KEY_A,
		"Move right": KEY_D,
		"Move forwards": KEY_W,
		"Move backwards": KEY_S,
		"Taunt": null
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	loadSettings()

func loadSettings():
	pass