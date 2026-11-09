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
@onready var invulnerability_on_button: Button = %InvulnerabilityOnButton
@onready var invulnerability_off_button: Button = %InvulnerabilityOffButton
@onready var duration_slider: HSlider = %DurationSlider
@onready var duration_value: Label = %DurationValue
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

	invulnerability_on_button.button_pressed = Settings.debug_hit_invulnerability
	invulnerability_off_button.button_pressed = not Settings.debug_hit_invulnerability
	invulnerability_on_button.pressed.connect(Settings.set_debug_hit_invulnerability.bind(true))
	invulnerability_off_button.pressed.connect(Settings.set_debug_hit_invulnerability.bind(false))

	duration_slider.min_value = Settings.MIN_INVULNERABILITY
	duration_slider.max_value = Settings.MAX_INVULNERABILITY
	duration_slider.value = Settings.debug_invulnerability_duration
	_show_duration(duration_slider.value)
	duration_slider.value_changed.connect(_on_duration_changed)
	# Beim Ziehen nicht ständig speichern, erst beim Loslassen
	duration_slider.drag_ended.connect(func(_changed: bool) -> void: Settings.save_settings())

	back_button.pressed.connect(close)


func _on_duration_changed(value: float) -> void:
	Settings.set_debug_invulnerability_duration(value, false)
	_show_duration(value)


func _show_duration(value: float) -> void:
	duration_value.text = "%.1f s" % value


func close() -> void:
	if _closing:
		return
	_closing = true
	Settings.save_settings()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# Esc am PC bzw. Zurück-Geste am Handy (siehe BackGesture)
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
