extends CenterContainer

# All Setting Variables
@onready var langSetting : OptionButton = $"MarginContainer/HBoxContainer/Buttons/Language"
@onready var camSensSetting : HSlider = $"MarginContainer/HBoxContainer/Buttons/HBoxContainer/Sensitivity"
@onready var yInvSetting : CheckButton = $"MarginContainer/HBoxContainer/Buttons/InverseY"
@onready var camShakeSetting : HSlider = $"MarginContainer/HBoxContainer/Buttons/HBoxContainer2/CamShake"
@onready var rumSetting : HSlider = $"MarginContainer/HBoxContainer/Buttons/HBoxContainer3/Rumble"

# All Numerics
@onready var camSensLabel : Label = $"MarginContainer/HBoxContainer/Buttons/HBoxContainer/Label"
@onready var camShakeLabel : Label = $"MarginContainer/HBoxContainer/Buttons/HBoxContainer2/Label"
@onready var rumLabel : Label = $"MarginContainer/HBoxContainer/Buttons/HBoxContainer3/Label"


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
