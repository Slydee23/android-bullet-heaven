class_name PauseMenu
extends Control
## Pause-/Statusbildschirm: hält das Spiel an, zeigt den Run-Status (ab M3) und führt zu Optionen oder zurück ins Hauptmenü.

signal closed

const PixelUI := preload("res://scripts/pixel_ui.gd")
const OPTIONS_MENU := preload("res://ui/options_menu.tscn")

## Held, dessen Werte angezeigt werden (setzt die Run-Szene vor dem Öffnen)
var player: Player

## Zweites Antippen von „Run aufgeben“ bestätigt (schützt vor versehentlichem Aufgeben)
var _abandon_armed := false

@onready var hp_label: Label = %HpLabel
@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var abandon_button: Button = %AbandonButton


func _ready() -> void:
	theme = PixelUI.make_theme()
	get_tree().paused = true
	if player:
		hp_label.text = tr("PAUSE_HP") % [ceili(player.hp), roundi(player.max_hp)]
	resume_button.pressed.connect(close)
	options_button.pressed.connect(_on_options_pressed)
	abandon_button.pressed.connect(_on_abandon_pressed)


func close() -> void:
	get_tree().paused = false
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# Esc am PC bzw. Zurück-Geste am Handy: weiterspielen
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _on_options_pressed() -> void:
	add_child(OPTIONS_MENU.instantiate())


func _on_abandon_pressed() -> void:
	if not _abandon_armed:
		_abandon_armed = true
		abandon_button.text = "PAUSE_ABANDON_CONFIRM"
		return
	# Bis M8 geht der Run dabei verloren
	SceneRouter.go_to_main_menu()
