extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Scene members

var _onBackPressed : bool = false

# All Setting Variables
@onready var langSetting : OptionButton = $"CenterContainer/MarginContainer/Labels/HBoxContainer1/LanguageButton"
@onready var camSensSetting : HSlider = $"CenterContainer/MarginContainer/Labels/HBoxContainer2/HBoxContainer/Sensitivity"
@onready var yInvSetting : CheckBox = $"CenterContainer/MarginContainer/Labels/HBoxContainer3/InverseY"

# All Numerics
@onready var camSensLabel : Label = $"CenterContainer/MarginContainer/Labels/HBoxContainer2/HBoxContainer/Label"

#endregion


#region Built-in functions

func _ready() -> void:
	# Initialize Language Settings
	langSetting.selected = Globals.settingsManager.SUPPORTED_LANGUAGES.find(Globals.settingsManager.getString("game", "language"))
	langSetting.item_selected.connect(_on_language_selected)

	# Initialize Camera Sensitivity Settins
	camSensSetting.value = Globals.settingsManager.getFloat("game", "camera sensitivity")
	camSensSetting.value_changed.connect(_on_sensitivity_changed)
	camSensLabel.text = str(camSensSetting.value)

	# Initialize Inverse Y Settins
	yInvSetting.button_pressed = Globals.settingsManager.getBool("game", "invert y")
	yInvSetting.toggled.connect(_on_y_inverse_toggled)

#endregion


#region Implementation functions

func type() -> Type:
	return Type.gameOptions

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
	
	if _onBackPressed:
		return BACK_MENU
		
	return Type.none

func _implDeactivate() -> void:
	_onBackPressed = false

#endregion


#region Signal functions

func _on_language_selected(index: int) -> void:
	Globals.settingsManager.setString("game", "language", Globals.settingsManager.SUPPORTED_LANGUAGES[index])

	Globals.settingsManager.saveSettings()
	Globals.settingsManager.applyGameSettings()


func _on_sensitivity_changed(value: float) -> void:
	Globals.settingsManager.setFloat("game", "camera sensitivity", value)
	camSensLabel.text = str(value)

	Globals.settingsManager.saveSettings()
	Globals.settingsManager.applyGameSettings()


func _on_y_inverse_toggled(status: bool) -> void:
	Globals.settingsManager.setBool("game", "invert y", status)

	Globals.settingsManager.saveSettings()
	Globals.settingsManager.applyGameSettings()


func _on_back_pressed() -> void:
	_onBackPressed = true

#endregion
