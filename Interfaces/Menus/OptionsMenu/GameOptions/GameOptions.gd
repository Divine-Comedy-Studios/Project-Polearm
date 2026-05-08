extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Scene members

# All Setting Variables
@onready var langSetting : OptionButton = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/Language"
@onready var camSensSetting : HSlider = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/HBoxContainer/Sensitivity"
@onready var yInvSetting : CheckButton = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/InverseY"
@onready var camShakeSetting : HSlider = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/HBoxContainer2/CamShake"
@onready var rumSetting : HSlider = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/HBoxContainer3/Rumble"

# All Numerics
@onready var camSensLabel : Label = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/HBoxContainer/Label"
@onready var camShakeLabel : Label = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/HBoxContainer2/Label"
@onready var rumLabel : Label = $"CenterContainer/MarginContainer/HBoxContainer/Buttons/HBoxContainer3/Label"

#endregion


#region Built-in functions

func _ready() -> void:
	# Initialize Language Settings
	langSetting.selected = SettingsManager.SUPPORTED_LANGUAGES.find(SettingsManager.getString("game", "language"))
	langSetting.item_selected.connect(_on_language_selected)

	# Initialize Camera Sensitivity Settins
	camSensSetting.value = SettingsManager.getFloat("game", "camera sensitivity")
	camSensSetting.value_changed.connect(_on_sensitivity_changed)
	camSensLabel.text = str(camSensSetting.value)

	# Initialize Inverse Y Settins
	yInvSetting.button_pressed = SettingsManager.getBool("game", "invert y")
	yInvSetting.toggled.connect(_on_y_inverse_toggled)

	# Initialize Camera Shake Settins
	camShakeSetting.value = SettingsManager.getFloat("game", "camera shake")
	camShakeSetting.value_changed.connect(_on_shake_changed)
	camShakeLabel.text = str(camShakeSetting.value)

	# Initialize Rumble Settins
	rumSetting.value = SettingsManager.getFloat("game", "rumble")
	rumSetting.value_changed.connect(_on_rumble_changed)
	rumLabel.text = str(rumSetting.value)

#endregion


#region Implementation functions

func type() -> Type:
	return Type.gameOptions

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
	return Type.none

#endregion


#region Signal functions

func _on_language_selected(index: int) -> void:
	SettingsManager.setInt("game", "language", index)

	SettingsManager.saveSettings()
	SettingsManager.applyGameSettings()


func _on_sensitivity_changed(value: float) -> void:
	SettingsManager.setFloat("game", "camera sensitivity", value)
	camSensLabel.text = str(value)

	SettingsManager.saveSettings()
	SettingsManager.applyGameSettings()


func _on_y_inverse_toggled(status: bool) -> void:
	SettingsManager.setBool("game", "invert y", status)

	SettingsManager.saveSettings()
	SettingsManager.applyGameSettings()


func _on_shake_changed(value: float) -> void:
	SettingsManager.setFloat("game", "camera shake", value)
	camShakeLabel.text = str(value)

	SettingsManager.saveSettings()
	SettingsManager.applyGameSettings()


func _on_rumble_changed(value: float) -> void:
	SettingsManager.setFloat("game", "rumble", value)
	rumLabel.text = str(value)

	SettingsManager.saveSettings()
	SettingsManager.applyGameSettings()

#endregion
