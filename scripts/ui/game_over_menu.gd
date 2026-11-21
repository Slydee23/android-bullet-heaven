extends Control
## Game Over: hält das Spiel an und führt zu einem neuen Run oder ins Hauptmenü.

const PixelUI := preload("res://scripts/ui/pixel_ui.gd")

## Sieg statt Niederlage (setzt die Run-Szene vor dem Einhängen), ob der Boss besiegt wurde und die Zusammenfassung des Runs
var victory := false
var boss_defeated := false
var summary: Dictionary = {}

@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	theme = PixelUI.make_theme()
	get_tree().paused = true
	if victory:
		get_node("Center/Content/Title").text = "VICTORY_TITLE"
	retry_button.pressed.connect(SceneRouter.start_run)
	main_menu_button.pressed.connect(SceneRouter.go_to_main_menu)


func _unhandled_input(event: InputEvent) -> void:
	# Esc bzw. Zurück-Geste öffnen hier nicht die Pause: Der Spieler entscheidet über die Knöpfe
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
