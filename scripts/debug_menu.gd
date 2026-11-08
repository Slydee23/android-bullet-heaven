extends Control
## Debug-Menü: kleines Fenster im Run, nur in Test-Builds (aus Godot gestartet) erreichbar.
## Testwerte zum Ausprobieren, wächst mit dem Spiel. Das Spiel kann dabei weiterlaufen (siehe Settings.debug_keep_running).

signal closed

const PixelUI := preload("res://scripts/pixel_ui.gd")

var _closing := false

@onready var zoom_near_button: Button = %ZoomNearButton
@onready var zoom_far_button: Button = %ZoomFarButton
@onready var zoom_dynamic_button: Button = %ZoomDynamicButton
@onready var game_paused_button: Button = %GamePausedButton
@onready var game_running_button: Button = %GameRunningButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	theme = PixelUI.make_theme()

	zoom_near_button.button_pressed = Settings.camera_zoom_mode == Settings.CameraZoomMode.NEAR
	zoom_far_button.button_pressed = Settings.camera_zoom_mode == Settings.CameraZoomMode.FAR
	zoom_dynamic_button.button_pressed = Settings.camera_zoom_mode == Settings.CameraZoomMode.DYNAMIC

	zoom_near_button.pressed.connect(Settings.set_camera_zoom_mode.bind(Settings.CameraZoomMode.NEAR))
	zoom_far_button.pressed.connect(Settings.set_camera_zoom_mode.bind(Settings.CameraZoomMode.FAR))
	zoom_dynamic_button.pressed.connect(Settings.set_camera_zoom_mode.bind(Settings.CameraZoomMode.DYNAMIC))

	game_paused_button.button_pressed = not Settings.debug_keep_running
	game_running_button.button_pressed = Settings.debug_keep_running
	game_paused_button.pressed.connect(Settings.set_debug_keep_running.bind(false))
	game_running_button.pressed.connect(Settings.set_debug_keep_running.bind(true))

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
