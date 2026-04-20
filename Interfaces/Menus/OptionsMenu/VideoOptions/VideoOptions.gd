extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Scene members

# All Buttons
@onready var windowMode := $"CernterContainer/MarginContainer/HBoxContainer/Buttons/WindowMode" as OptionButton
@onready var resolution := $"CernterContainer/MarginContainer/HBoxContainer/Buttons/Resolution" as OptionButton
@onready var vSync := $"CernterContainer/MarginContainer/HBoxContainer/Buttons/Vsync" as CheckButton
@onready var gamma := $"CernterContainer/MarginContainer/HBoxContainer/Buttons/Gamma/Gamma" as HSlider

# All Numerics
@onready var gammaLabel := $"CernterContainer/MarginContainer/HBoxContainer/Buttons/Gamma/Label" as Label

#endregion


#region Built-in functions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize Window Mode
	windowMode.selected = SettingsManager.Settings["video"]["window mode"]
	windowMode.item_selected.connect(_on_window_mode_selected)

	# Initialize Resolution
	resolution.selected = SettingsManager.Settings["video"]["resolution"]
	resolution.item_selected.connect(_on_resolution_selected)

	# Initialize Vsync
	vSync.button_pressed = SettingsManager.Settings["video"]["vsync"]
	vSync.toggled.connect(_on_vsync_toggled)

	# Initialize Gamma Settings
	gamma.value = SettingsManager.Settings["video"]["gamma"]
	gamma.value_changed.connect(_on_gamma_value_changed)
	gammaLabel.text = str(gamma.value)

#endregion


#region Override functions

func type() -> Type:
	return Type.videoOptions

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
	return Type.none


#endregion


#region Signal functions

func _on_window_mode_selected(index : int) -> void:
	SettingsManager.Settings["video"]["window mode"] = index

	resolution.disabled = (index == 1) # if Fullscreen then resolution disabled

	SettingsManager.saveSettings()
	SettingsManager.applyVideo()

func _on_resolution_selected(index : int) -> void:
	SettingsManager.Settings["video"]["resolution"] = index

	SettingsManager.saveSettings()
	SettingsManager.applyVideo()

func _on_vsync_toggled(status : bool) -> void:
	SettingsManager.Settings["video"]["vsync"] = status

	SettingsManager.saveSettings()
	SettingsManager.applyGame()

func _on_gamma_value_changed(value : float) -> void:
	SettingsManager.Settings["video"]["gamma"] = value
	gammaLabel.text = str(value)

	SettingsManager.saveSettings()
	SettingsManager.applyVideo()

#endregion
