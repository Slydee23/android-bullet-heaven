extends Control
## Hauptmenü: vorerst nur "Run starten".

const PixelUI := preload("res://scripts/pixel_ui.gd")

const RUN_SCENE := "res://scenes/run.tscn"
const BUTTON_TEXTURE := preload("res://assets/ui/button.png")
## Randbreite der 9-Slice-Button-Textur (Pixel)
const BUTTON_MARGIN := 4

@onready var start_button: Button = %StartButton


func _ready() -> void:
	var style := PixelUI.nine_slice(BUTTON_TEXTURE, BUTTON_MARGIN)
	var pressed_style := style.duplicate() as StyleBoxTexture
	pressed_style.modulate_color = Color(0.7, 0.7, 0.7)
	start_button.add_theme_stylebox_override("normal", style)
	start_button.add_theme_stylebox_override("hover", style)
	start_button.add_theme_stylebox_override("pressed", pressed_style)
	start_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(RUN_SCENE)
