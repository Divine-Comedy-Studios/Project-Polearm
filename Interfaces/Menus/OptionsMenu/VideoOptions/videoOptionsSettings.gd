extends CenterContainer

# All Buttons
@onready var windowMode : OptionButton = $"MarginContainer/HBoxContainer/Buttons/WindowMode"
@onready var resolution : OptionButton = $"MarginContainer/HBoxContainer/Buttons/Resolution"
@onready var vSynch : CheckButton = $"MarginContainer/HBoxContainer/Buttons/Vsync"
@onready var gamma : HSlider = $"MarginContainer/HBoxContainer/Buttons/Gamma/Gamma"

# All Numerics
@onready var gammaLabel : Label = $"MarginContainer/HBoxContainer/Buttons/Gamma/Label"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Initialize Window Mode
	windowMode.selected = SettingsManager.getInt("video", "window mode")
	windowMode.item_selected.connect(_on_window_mode_selected)

	# Initialize Resolution
	resolution.selected = SettingsManager.getInt("video", "resolution")
	resolution.item_selected.connect(_on_resolution_selected)

	# Initialize Vsync
	vSynch.button_pressed = SettingsManager.getBool("video", "vsync")
	vSynch.toggled.connect(_on_vsync_toggled)

	# Initialize Gamma Settings
	gamma.value = SettingsManager.getFloat("video", "gamma")
	gamma.value_changed.connect(_on_gamma_value_changed)
	gammaLabel.text = str(gamma.value)


func _on_window_mode_selected(index: int) -> void:
	SettingsManager.setInt("video", "window mode", index)

	resolution.disabled = (index == 1) # if Fullscreen then resolution disabled

	SettingsManager.saveSettings()
	SettingsManager.applyVideoSettings()

func _on_resolution_selected(index: int) -> void:
	SettingsManager.setInt("video", "resolution", index)

	SettingsManager.saveSettings()
	SettingsManager.applyVideoSettings()

func _on_vsync_toggled(status: bool) -> void:
	SettingsManager.setBool("video", "vsync", status)

	SettingsManager.saveSettings()
	SettingsManager.applyGameSettings()

func _on_gamma_value_changed(value: float) -> void:
	SettingsManager.setFloat("video", "gamma", value)
	gammaLabel.text = str(value)

	SettingsManager.saveSettings()
	SettingsManager.applyVideoSettings()
