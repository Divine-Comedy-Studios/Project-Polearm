extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Scene members

# All Buttons
@onready var masterVolume : HSlider = $"CenterContainer/MarginContainer/HBoxContainer/Label/HBoxContainer/HBoxContainer/Master" 
@onready var musicVolume : HSlider = $"CenterContainer/MarginContainer/HBoxContainer/Label/HBoxContainer2/HBoxContainer2/Music" 
@onready var sfxVolume : HSlider = $"CenterContainer/MarginContainer/HBoxContainer/Label/HBoxContainer3/HBoxContainer3/Sfx" 

# All Numerics
@onready var masterVolumeLabel : Label = $"CenterContainer/MarginContainer/HBoxContainer/Label/HBoxContainer/HBoxContainer/Label" 
@onready var musicVolumeLabel : Label = $"CenterContainer/MarginContainer/HBoxContainer/Label/HBoxContainer2/HBoxContainer2/Label" 
@onready var sfxVolumeLabel : Label = $"CenterContainer/MarginContainer/HBoxContainer/Label/HBoxContainer3/HBoxContainer3/Label" 

#endregion


#region Built-in functions

func _ready() -> void:
	# Initialize Master Volume
	masterVolume.value = SettingsManager.getFloat("audio", "master")
	masterVolume.value_changed.connect(_on_master_value_changed)
	masterVolumeLabel.text = str(int(masterVolume.value*100))

	# Initialize Master Volume
	musicVolume.value = SettingsManager.getFloat("audio", "music")
	musicVolume.value_changed.connect(_on_music_value_changed)
	musicVolumeLabel.text = str(int(musicVolume.value*100))

	# Initialize Master Volume
	sfxVolume.value = SettingsManager.getFloat("audio", "sfx")
	sfxVolume.value_changed.connect(_on_sfx_value_changed)
	sfxVolumeLabel.text = str(int(sfxVolume.value*100))

#endregion


#region Implementation functions

func type() -> Type:
	return Type.audioOptions

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
	return Type.none

#endregion


#region Signal functions

func _on_master_value_changed(value: float) -> void:
	SettingsManager.setFloat("audio", "master", value)
	masterVolumeLabel.text = str(int(value*100))

	SettingsManager.saveSettings()
	SettingsManager.applyAudioSettings()

func _on_music_value_changed(value: float) -> void:
	SettingsManager.setFloat("audio", "music", value)
	musicVolumeLabel.text = str(int(value*100))

	SettingsManager.saveSettings()
	SettingsManager.applyAudioSettings()


func _on_sfx_value_changed(value: float) -> void:
	SettingsManager.setFloat("audio", "sfx", value)
	sfxVolumeLabel.text = str(int(value*100))

	SettingsManager.saveSettings()
	SettingsManager.applyAudioSettings()

#endregion
