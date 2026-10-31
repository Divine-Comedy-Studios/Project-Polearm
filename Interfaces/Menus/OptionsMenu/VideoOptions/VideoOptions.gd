extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Scene members

var _onBackPressed : bool = false

# All Buttons
@onready var windowMode : OptionButton = $"CenterContainer/MarginContainer/HBoxContainer/Labels/HBoxContainer/WindowMode2"
@onready var vSynch : CheckBox = $"CenterContainer/MarginContainer/HBoxContainer/Labels/HBoxContainer3/Vsync2"
@onready var gamma : HSlider = $"CenterContainer/MarginContainer/HBoxContainer/Labels/HBoxContainer4/Gamma2/Gamma"

# All Numerics
@onready var gammaLabel : Label = $"CenterContainer/MarginContainer/HBoxContainer/Labels/HBoxContainer4/Gamma2/Label"

#endregion


#region Built-in functions

func _ready() -> void:
	# Initialize Window Mode
	windowMode.selected = Globals.settingsManager.getInt("video", "window mode")
	windowMode.item_selected.connect(_on_window_mode_selected)

	# Initialize Vsync
	vSynch.button_pressed = Globals.settingsManager.getBool("video", "vsync")
	vSynch.toggled.connect(_on_vsync_toggled)

	# Initialize Gamma Settings
	gamma.value = Globals.settingsManager.getFloat("video", "gamma")
	gamma.value_changed.connect(_on_gamma_value_changed)
	gammaLabel.text = str(gamma.value)

#endregion


#region Implementation functions

func type() -> Type:
	return Type.videoOptions

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
	
	if _onBackPressed:
		return BACK_MENU
		
	return Type.none

func _deactivateImpl() -> void:
	_onBackPressed = false

#endregion


#region Signal functions

func _on_window_mode_selected(index : int) -> void:
	Globals.settingsManager.setInt("video", "window mode", index)

	Globals.settingsManager.saveSettings()
	Globals.settingsManager.applyVideoSettings()

func _on_vsync_toggled(status : bool) -> void:
	Globals.settingsManager.setBool("video", "vsync", status)

	Globals.settingsManager.saveSettings()
	Globals.settingsManager.applyVideoSettings()

func _on_gamma_value_changed(value : float) -> void:
	Globals.settingsManager.setFloat("video", "gamma", value)
	gammaLabel.text = str(value)

	Globals.settingsManager.saveSettings()
	Globals.settingsManager.applyVideoSettings()
	
func _on_back_pressed() -> void:
	_onBackPressed = true

#endregion
