extends Control
## Debug-Menü: nur in Test-Builds (aus Godot gestartet) erreichbar. Testwerte zum Ausprobieren, wächst mit dem Spiel.

signal closed

const PixelUI := preload("res://scripts/pixel_ui.gd")

var _closing := false

@onready var zoom_near_button: Button = %ZoomNearButton
@onready var zoom_far_button: Button = %ZoomFarButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	theme = PixelUI.make_theme()

	zoom_near_button.button_pressed = is_equal_approx(Settings.camera_zoom, Settings.ZOOM_NEAR)
	zoom_far_button.button_pressed = is_equal_approx(Settings.camera_zoom, Settings.ZOOM_FAR)

	zoom_near_button.pressed.connect(Settings.set_camera_zoom.bind(Settings.ZOOM_NEAR))
	zoom_far_button.pressed.connect(Settings.set_camera_zoom.bind(Settings.ZOOM_FAR))
	back_button.pressed.connect(close)


func close() -> void:
	if _closing:
		return
	_closing = true
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# Esc am PC bzw. Zurück-Geste am Handy (siehe BackGesture)
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
