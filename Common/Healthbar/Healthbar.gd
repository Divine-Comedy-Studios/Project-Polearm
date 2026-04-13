class_name HealthBar extends Sprite3D

#region Exported Variables

@export var SIZE := Vector2(1000, 50)
@export var HEALTH_GRADIENT : Gradient
@export var MAX_HEALTH : int = 100

#endregion 

@onready var subViewport : SubViewport = $"SubViewport" 
@onready var panel : Panel = $"SubViewport/Panel"
@onready var healthBar : TextureProgressBar = $"SubViewport/Panel/Healthbar"
@onready var damageBar : TextureProgressBar = $"SubViewport/Panel/Healthbar/Damagebar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.size = SIZE
	subViewport.size = SIZE
	updateHealth(MAX_HEALTH)


func updateHealth(currentHealth: float, maxHealth: float = MAX_HEALTH) -> void:

	var healthRatio = currentHealth/healthBar.max_value

	healthBar.max_value = maxHealth
	healthBar.value = currentHealth

	if HEALTH_GRADIENT:
		healthBar.self_modulate = HEALTH_GRADIENT.sample(healthRatio)
