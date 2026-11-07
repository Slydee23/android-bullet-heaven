extends Control
## Hauptmenü: Run starten und Optionen.

const PixelUI := preload("res://scripts/pixel_ui.gd")

const RUN_SCENE := "res://scenes/run.tscn"
const OPTIONS_MENU := preload("res://ui/options_menu.tscn")

@onready var start_button: Button = %StartButton
@onready var options_button: Button = %OptionsButton
@onready var version_label: Label = %VersionLabel


func _ready() -> void:
	theme = PixelUI.make_theme()
	# Version steht zentral in Projekteinstellungen → Anwendung → Konfiguration → Version
	version_label.text = ProjectSettings.get_setting("application/config/version", "")

	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(RUN_SCENE)


func _on_options_button_pressed() -> void:
	add_child(OPTIONS_MENU.instantiate())
