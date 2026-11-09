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
## Regler-Grenzen der I-Frames im Debug-Menü
const MIN_IFRAME_DURATION := 0.05
const MAX_IFRAME_DURATION := 2.0
const MIN_IFRAME_SHARE := 0.05
const MAX_IFRAME_SHARE := 0.5
## Kein Testwert gesetzt: Es gilt data/combat/player_iframes.tres
const IFRAME_NOT_SET := -1.0
## Kamera-Zoom zum Vergleichen (Debug-Menü): Nah 3×, Weit 2,25×, Dynamisch nach Gegnerdruck (siehe RunCamera)
enum CameraZoomMode { NEAR, FAR, DYNAMIC }

var joystick_mode := JoystickMode.FLOATING
var joystick_side := JoystickSide.BOTH
## Deckkraft des Joysticks, 0.2..1.0
var joystick_opacity := 1.0
## Nur Testwert (Debug-Menü), bis der Zoom entschieden ist
var camera_zoom_mode := CameraZoomMode.DYNAMIC
## Nur Testwert (Debug-Menü): Spiel läuft weiter, während das Debug-Menü offen ist
var debug_keep_running := false
## Nur Testwerte (Debug-Menü): I-Frames ausprobieren, ohne die Datendatei zu ändern
var debug_iframe_min := IFRAME_NOT_SET
var debug_iframe_max := IFRAME_NOT_SET
var debug_iframe_share := IFRAME_NOT_SET
var show_player_health_bar := true


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
	var zoom_mode: int = config.get_value("debug", "camera_zoom_mode", camera_zoom_mode)
	if zoom_mode in CameraZoomMode.values():
		camera_zoom_mode = zoom_mode as CameraZoomMode
	var keep_running: bool = config.get_value("debug", "keep_running", debug_keep_running)
	debug_keep_running = keep_running
	var iframe_min: float = config.get_value("debug", "iframe_min", IFRAME_NOT_SET)
	var iframe_max: float = config.get_value("debug", "iframe_max", IFRAME_NOT_SET)
	var iframe_share: float = config.get_value("debug", "iframe_share", IFRAME_NOT_SET)
	if iframe_min >= 0.0 and iframe_max >= 0.0 and iframe_share >= 0.0:
		_store_debug_iframes(iframe_min, iframe_max, iframe_share)
	var health_bar: bool = config.get_value("display", "player_health_bar", show_player_health_bar)
	show_player_health_bar = health_bar


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("meta", "version", FILE_VERSION)
	config.set_value("controls", "joystick_mode", joystick_mode)
	config.set_value("controls", "joystick_side", joystick_side)
	config.set_value("controls", "joystick_opacity", joystick_opacity)
	config.set_value("debug", "camera_zoom_mode", camera_zoom_mode)
	config.set_value("debug", "keep_running", debug_keep_running)
	config.set_value("debug", "iframe_min", debug_iframe_min)
	config.set_value("debug", "iframe_max", debug_iframe_max)
	config.set_value("debug", "iframe_share", debug_iframe_share)
	config.set_value("display", "player_health_bar", show_player_health_bar)
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


func set_camera_zoom_mode(mode: CameraZoomMode) -> void:
	camera_zoom_mode = mode
	_apply()


func set_debug_keep_running(keep_running: bool) -> void:
	debug_keep_running = keep_running
	_apply()


func has_debug_iframes() -> bool:
	return debug_iframe_min >= 0.0


## persist = false: nur übernehmen, nicht speichern (z. B. während ein Schieberegler gezogen wird)
func set_debug_iframes(minimum: float, maximum: float, share: float, persist := true) -> void:
	_store_debug_iframes(minimum, maximum, share)
	_apply(persist)


## Testwerte verwerfen: Es gilt wieder die Datendatei.
func reset_debug_iframes() -> void:
	debug_iframe_min = IFRAME_NOT_SET
	debug_iframe_max = IFRAME_NOT_SET
	debug_iframe_share = IFRAME_NOT_SET
	_apply()


func _store_debug_iframes(minimum: float, maximum: float, share: float) -> void:
	debug_iframe_min = clampf(minimum, MIN_IFRAME_DURATION, MAX_IFRAME_DURATION)
	debug_iframe_max = clampf(maximum, debug_iframe_min, MAX_IFRAME_DURATION)
	debug_iframe_share = clampf(share, MIN_IFRAME_SHARE, MAX_IFRAME_SHARE)


func set_show_player_health_bar(show_bar: bool) -> void:
	show_player_health_bar = show_bar
	_apply()


func _apply(persist := true) -> void:
	if persist:
		save_settings()
	changed.emit()
