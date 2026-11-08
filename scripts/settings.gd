extends Node
## Spieler-Einstellungen (Autoload "Settings"): werden in user://settings.cfg gespeichert.

signal changed

enum JoystickMode { FLOATING, FIXED }
## Bildschirmseite, auf der der Joystick startet. BOTH gibt es nur bei FLOATING.
enum JoystickSide { LEFT, RIGHT, BOTH }

const PATH := "user://settings.cfg"
## Erhöhen, wenn sich das Dateiformat ändert (alte Dateien lassen sich dann umwandeln)
const FILE_VERSION := 1
const MIN_JOYSTICK_OPACITY := 0.2
## Kamera-Zoom-Stufen zum Vergleichen (Debug-Menü): Nah zeigt weniger, Weit mehr Spielwelt
const ZOOM_NEAR := 4.0
const ZOOM_FAR := 3.0

var joystick_mode := JoystickMode.FLOATING
var joystick_side := JoystickSide.BOTH
## Deckkraft des Joysticks, 0.2..1.0
var joystick_opacity := 1.0
## Nur Testwert (Debug-Menü), bis der Zoom entschieden ist
var camera_zoom := ZOOM_NEAR


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return  # Erster Start: Standardwerte behalten
	var mode: int = config.get_value("controls", "joystick_mode", joystick_mode)
	if mode in JoystickMode.values():
		joystick_mode = mode as JoystickMode
	var side: int = config.get_value("controls", "joystick_side", joystick_side)
	if side in JoystickSide.values():
		joystick_side = side as JoystickSide
	# Fester Joystick braucht eine eindeutige Seite
	if joystick_mode == JoystickMode.FIXED and joystick_side == JoystickSide.BOTH:
		joystick_side = JoystickSide.LEFT
	var opacity: float = config.get_value("controls", "joystick_opacity", joystick_opacity)
	joystick_opacity = clampf(opacity, MIN_JOYSTICK_OPACITY, 1.0)
	var zoom: float = config.get_value("debug", "camera_zoom", camera_zoom)
	if is_equal_approx(zoom, ZOOM_NEAR) or is_equal_approx(zoom, ZOOM_FAR):
		camera_zoom = zoom


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("meta", "version", FILE_VERSION)
	config.set_value("controls", "joystick_mode", joystick_mode)
	config.set_value("controls", "joystick_side", joystick_side)
	config.set_value("controls", "joystick_opacity", joystick_opacity)
	config.set_value("debug", "camera_zoom", camera_zoom)
	# Sicher schreiben: erst temporäre Datei, dann ersetzen
	var temp_path := PATH + ".tmp"
	if config.save(temp_path) == OK:
		DirAccess.rename_absolute(temp_path, PATH)


func set_joystick_mode(mode: JoystickMode) -> void:
	joystick_mode = mode
	_apply()


func set_joystick_side(side: JoystickSide) -> void:
	joystick_side = side
	_apply()


## persist = false: nur übernehmen, nicht speichern (z. B. während ein Schieberegler gezogen wird)
func set_joystick_opacity(opacity: float, persist := true) -> void:
	joystick_opacity = clampf(opacity, MIN_JOYSTICK_OPACITY, 1.0)
	_apply(persist)


func set_camera_zoom(zoom: float) -> void:
	camera_zoom = zoom
	_apply()


func _apply(persist := true) -> void:
	if persist:
		save_settings()
	changed.emit()
