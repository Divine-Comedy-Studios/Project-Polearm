extends CenterContainer

# All Buttons
@onready var masterVolume : HSlider = $"MarginContainer/HBoxContainer/Slider/HBoxContainer/Master" 
@onready var musicVolume : HSlider = $"MarginContainer/HBoxContainer/Slider/HBoxContainer2/Music" 
@onready var sfxVolume : HSlider = $"MarginContainer/HBoxContainer/Slider/HBoxContainer3/Sfx" 

# All Numerics
@onready var masterVolumeLabel : Label = $"MarginContainer/HBoxContainer/Slider/HBoxContainer/Label" 
@onready var musicVolumeLabel : Label = $"MarginContainer/HBoxContainer/Slider/HBoxContainer2/Label" 
@onready var sfxVolumeLabel : Label = $"MarginContainer/HBoxContainer/Slider/HBoxContainer3/Label" 

func _ready() -> void:
	# Initialize Master Volume
	masterVolume.value = SettingsManager.Settings["audio"]["master"]
	masterVolume.value_changed.connect(_on_master_value_changed)
	masterVolumeLabel.text = str(int(masterVolume.value*100))+"%"

	# Initialize Master Volume
	musicVolume.value = SettingsManager.Settings["audio"]["music"]
	musicVolume.value_changed.connect(_on_music_value_changed)
	musicVolumeLabel.text = str(int(musicVolume.value*100))+"%"

	# Initialize Master Volume
	sfxVolume.value = SettingsManager.Settings["audio"]["sfx"]
	sfxVolume.value_changed.connect(_on_sfx_value_changed)
	sfxVolumeLabel.text = str(int(sfxVolume.value*100))+"%"

func _on_master_value_changed(value: float) -> void:
	SettingsManager.Settings["audio"]["master"] = value
	masterVolumeLabel.text = str(int(value*100))+"%"

	SettingsManager.saveSettings()
	SettingsManager.applyAudio()

func _on_music_value_changed(value: float) -> void:
	SettingsManager.Settings["audio"]["music"] = value
	musicVolumeLabel.text = str(int(value*100))+"%"

	SettingsManager.saveSettings()
	SettingsManager.applyAudio()


func _on_sfx_value_changed(value: float) -> void:
	SettingsManager.Settings["audio"]["sfx"] = value
	sfxVolumeLabel.text = str(int(value*100))+"%"

	SettingsManager.saveSettings()
	SettingsManager.applyAudio()
