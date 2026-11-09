extends Control
## Optionsmenü: wird aus dem Hauptmenü und aus der Pause geöffnet und schließt sich selbst.

signal closed

const PixelUI := preload("res://scripts/pixel_ui.gd")

var _closing := false

@onready var floating_button: Button = %FloatingButton
@onready var fixed_button: Button = %FixedButton
@onready var left_button: Button = %LeftButton
@onready var right_button: Button = %RightButton
@onready var both_button: Button = %BothButton
@onready var opacity_slider: HSlider = %OpacitySlider
@onready var opacity_value: Label = %OpacityValue
@onready var health_bar_on_button: Button = %HealthBarOnButton
@onready var health_bar_off_button: Button = %HealthBarOffButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	theme = PixelUI.make_theme()

	# Aktuelle Einstellungen anzeigen
	floating_button.button_pressed = Settings.joystick_mode == Settings.JoystickMode.FLOATING
	fixed_button.button_pressed = Settings.joystick_mode == Settings.JoystickMode.FIXED
	left_button.button_pressed = Settings.joystick_side == Settings.JoystickSide.LEFT
	right_button.button_pressed = Settings.joystick_side == Settings.JoystickSide.RIGHT
	both_button.button_pressed = Settings.joystick_side == Settings.JoystickSide.BOTH
	# Der Regler zeigt Transparenz (0 % = voll sichtbar), gespeichert wird die Deckkraft
	opacity_slider.max_value = (1.0 - Settings.MIN_JOYSTICK_OPACITY) * 100.0
	opacity_slider.value = (1.0 - Settings.joystick_opacity) * 100.0
	_show_transparency(opacity_slider.value)
	_update_side_buttons()

	floating_button.pressed.connect(_on_mode_pressed.bind(Settings.JoystickMode.FLOATING))
	fixed_button.pressed.connect(_on_mode_pressed.bind(Settings.JoystickMode.FIXED))
	left_button.pressed.connect(Settings.set_joystick_side.bind(Settings.JoystickSide.LEFT))
	right_button.pressed.connect(Settings.set_joystick_side.bind(Settings.JoystickSide.RIGHT))
	both_button.pressed.connect(Settings.set_joystick_side.bind(Settings.JoystickSide.BOTH))
	opacity_slider.value_changed.connect(_on_transparency_changed)
	# Beim Ziehen nicht ständig speichern, erst beim Loslassen
	opacity_slider.drag_ended.connect(func(_changed: bool) -> void: Settings.save_settings())
	health_bar_on_button.button_pressed = Settings.show_player_health_bar
	health_bar_off_button.button_pressed = not Settings.show_player_health_bar
	health_bar_on_button.pressed.connect(Settings.set_show_player_health_bar.bind(true))
	health_bar_off_button.pressed.connect(Settings.set_show_player_health_bar.bind(false))
	back_button.pressed.connect(close)


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


func _on_mode_pressed(mode: Settings.JoystickMode) -> void:
	# Ein fester Joystick braucht eine eindeutige Seite: aus „Beide“ wird „Links“
	if mode == Settings.JoystickMode.FIXED and Settings.joystick_side == Settings.JoystickSide.BOTH:
		Settings.joystick_side = Settings.JoystickSide.LEFT
		left_button.button_pressed = true
	Settings.set_joystick_mode(mode)
	_update_side_buttons()


func _update_side_buttons() -> void:
	both_button.disabled = Settings.joystick_mode == Settings.JoystickMode.FIXED


func _on_transparency_changed(value: float) -> void:
	Settings.set_joystick_opacity(1.0 - value / 100.0, false)
	_show_transparency(value)


func _show_transparency(value: float) -> void:
	opacity_value.text = "%d %%" % int(value)
