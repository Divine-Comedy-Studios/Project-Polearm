extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Scene members

# All Buttons
@onready var windowMode : OptionButton = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/WindowMode"
@onready var resolution : OptionButton = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/Resolution"
@onready var vSynch : CheckButton = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/Vsync"
@onready var gamma : HSlider = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/Gamma/Gamma"

# All Numerics
@onready var gammaLabel : Label = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/Gamma/Label"

#endregion


#region Built-in functions

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

#endregion


#region Implementation functions

func type() -> Type:
	return Type.videoOptions

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
	return Type.none

#endregion


#region Signal functions

func _on_window_mode_selected(index : int) -> void:
	SettingsManager.setInt("video", "window mode", index)

	resolution.disabled = (index == 1) # if Fullscreen then resolution disabled

	SettingsManager.saveSettings()
	SettingsManager.applyVideoSettings()

func _on_resolution_selected(index : int) -> void:
	SettingsManager.setInt("video", "resolution", index)

	SettingsManager.saveSettings()
	SettingsManager.applyVideoSettings()

func _on_vsync_toggled(status : bool) -> void:
	SettingsManager.setBool("video", "vsync", status)

	SettingsManager.saveSettings()
	SettingsManager.applyGameSettings()

func _on_gamma_value_changed(value : float) -> void:
	SettingsManager.setFloat("video", "gamma", value)
	gammaLabel.text = str(value)

	SettingsManager.saveSettings()
	SettingsManager.applyVideoSettings()

#endregion
