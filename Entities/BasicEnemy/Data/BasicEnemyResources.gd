extends EntityResources
class_name BasicEnemyResources


@export var _healthBar : ValueBarUI = null


func _ready() -> void:
	super._ready()

	if _healthBar:
		_healthBar.valueResource = health
