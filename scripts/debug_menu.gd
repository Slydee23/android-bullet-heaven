class_name DebugMenu
extends Control
## Debug-Menü: kleines Fenster im Run, nur in Test-Builds (aus Godot gestartet) erreichbar.
## Testwerte zum Ausprobieren, wächst mit dem Spiel. Das Spiel kann dabei weiterlaufen (siehe Settings.debug_keep_running).

signal closed

const PixelUI := preload("res://scripts/pixel_ui.gd")
## Testknöpfe: Anteil der maximalen HP
const TEST_HIT_SHARE := 0.2
const TEST_SELF_DAMAGE_SHARE := 0.1

## Held, auf den sich die Testwerte beziehen (setzt die Run-Szene vor dem Öffnen)
var player: Player

var _closing := false
var _shown_iframes := -1.0

@onready var zoom_near_button: Button = %ZoomNearButton
@onready var zoom_far_button: Button = %ZoomFarButton
@onready var zoom_dynamic_button: Button = %ZoomDynamicButton
@onready var game_paused_button: Button = %GamePausedButton
@onready var game_running_button: Button = %GameRunningButton
@onready var iframe_min_slider: HSlider = %IFrameMinSlider
@onready var iframe_min_value: Label = %IFrameMinValue
@onready var iframe_max_slider: HSlider = %IFrameMaxSlider
@onready var iframe_max_value: Label = %IFrameMaxValue
@onready var iframe_share_slider: HSlider = %IFrameShareSlider
@onready var iframe_share_value: Label = %IFrameShareValue
@onready var iframe_last_label: Label = %IFrameLastLabel
@onready var test_hit_button: Button = %TestHitButton
@onready var test_self_damage_button: Button = %TestSelfDamageButton
@onready var iframe_reset_button: Button = %IFrameResetButton
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

	_setup_iframe_slider(iframe_min_slider, Settings.MIN_IFRAME_DURATION, Settings.MAX_IFRAME_DURATION)
	_setup_iframe_slider(iframe_max_slider, Settings.MIN_IFRAME_DURATION, Settings.MAX_IFRAME_DURATION)
	_setup_iframe_slider(iframe_share_slider, Settings.MIN_IFRAME_SHARE, Settings.MAX_IFRAME_SHARE)
	_show_iframe_rule()
	iframe_min_slider.value_changed.connect(_on_iframe_min_changed)
	iframe_max_slider.value_changed.connect(_on_iframe_max_changed)
	iframe_share_slider.value_changed.connect(_on_iframe_slider_changed)

	test_hit_button.pressed.connect(_on_test_hit_pressed)
	test_self_damage_button.pressed.connect(_on_test_self_damage_pressed)
	iframe_reset_button.pressed.connect(_on_iframe_reset_pressed)
	back_button.pressed.connect(close)


func _process(_delta: float) -> void:
	if player and player.last_iframe_duration != _shown_iframes:
		_shown_iframes = player.last_iframe_duration
		iframe_last_label.text = tr("DEBUG_IFRAME_LAST") % _shown_iframes


func _setup_iframe_slider(slider: HSlider, minimum: float, maximum: float) -> void:
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = 0.01
	# Beim Ziehen nicht ständig speichern, erst beim Loslassen
	slider.drag_ended.connect(func(_changed: bool) -> void: Settings.save_settings())


## Zeigt die geltende Regel des Helden an, ohne dabei die Regler-Signale auszulösen.
func _show_iframe_rule() -> void:
	iframe_min_slider.set_value_no_signal(player.iframe_rule.min_duration)
	iframe_max_slider.set_value_no_signal(player.iframe_rule.max_duration)
	iframe_share_slider.set_value_no_signal(player.iframe_rule.reference_share)
	iframe_min_value.text = "%.2f s" % iframe_min_slider.value
	iframe_max_value.text = "%.2f s" % iframe_max_slider.value
	iframe_share_value.text = "%d %%" % roundi(iframe_share_slider.value * 100.0)


## Die Mindestdauer schiebt die Höchstdauer mit, damit sie nie darüber liegt.
func _on_iframe_min_changed(value: float) -> void:
	if value > iframe_max_slider.value:
		iframe_max_slider.set_value_no_signal(value)
	_on_iframe_slider_changed(value)


## Die Höchstdauer schiebt die Mindestdauer mit, damit sie nie darunter liegt.
func _on_iframe_max_changed(value: float) -> void:
	if value < iframe_min_slider.value:
		iframe_min_slider.set_value_no_signal(value)
	_on_iframe_slider_changed(value)


func _on_iframe_slider_changed(_value: float) -> void:
	Settings.set_debug_iframes(iframe_min_slider.value, iframe_max_slider.value, iframe_share_slider.value, false)
	_show_iframe_rule()


func _on_test_hit_pressed() -> void:
	player.take_damage(player.max_hp * TEST_HIT_SHARE)


func _on_test_self_damage_pressed() -> void:
	player.take_self_damage(player.max_hp * TEST_SELF_DAMAGE_SHARE)


func _on_iframe_reset_pressed() -> void:
	Settings.reset_debug_iframes()
	_show_iframe_rule()


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
