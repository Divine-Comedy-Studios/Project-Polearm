extends GameState


#region Imports

const Game := preload("res://Core/Game/Game.gd")

#endregion


#region Exported variables

@export var FADE_TIME : float = 1.2

#endregion


#region Scene members

@onready var _ui := $UI as CanvasLayer
@onready var _tint := $UI/Tint as ColorRect
@onready var _content := $UI/Center as CenterContainer
@onready var _respawnButton := $UI/Center/VBox/RespawnButton as Button
@onready var _menuButton := $UI/Center/VBox/MainMenuButton as Button

#endregion


#region Member variables

var _nextGameState : StringName = Type.none
var _stageType : Variant = null # Stage to reload on respawn, handed over by the World
var _tween : Tween = null

#endregion


#region Built-in functions

func _ready() -> void:
	_ui.hide()
	_respawnButton.pressed.connect(_SIG_respawnPressed)
	_menuButton.pressed.connect(_SIG_mainMenuPressed)

#endregion


#region Override functions

func _enter() -> void:
	_nextGameState = Type.none
	_stageType = (stateMachine as Game).payload # The World hands us the stage it was running

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Fade in, buttons only become clickable afterwards so a mashed attack key can't skip the screen
	_respawnButton.disabled = true
	_menuButton.disabled = true
	_tint.modulate.a = 0.0
	_content.modulate.a = 0.0
	_ui.show()

	_tween = create_tween()
	_tween.tween_property(_tint, "modulate:a", 1.0, FADE_TIME)
	_tween.tween_property(_content, "modulate:a", 1.0, FADE_TIME * 0.5)
	_tween.tween_callback(_enableButtons)


func _exit() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null

	_ui.hide()
	_nextGameState = Type.none


func type() -> StringName:
	return Type.death

func nextState() -> StringName:
	return _nextGameState

#endregion


#region Private functions

func _enableButtons() -> void:
	_respawnButton.disabled = false
	_menuButton.disabled = false
	_respawnButton.grab_focus()

#endregion


#region Signal functions

func _SIG_respawnPressed() -> void:
	# Handing the stage type on makes the World reload it through the loading screen
	payload = _stageType
	_nextGameState = Type.world


func _SIG_mainMenuPressed() -> void:
	# Same route the pause menu uses to get back to the main menu
	(stateMachine as Game).exitState = Type.mainMenu

#endregion
