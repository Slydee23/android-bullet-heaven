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
const MIN_INVULNERABILITY := 0.1
const MAX_INVULNERABILITY := 2.0
## Kamera-Zoom zum Vergleichen (Debug-Menü): Nah 4×, Weit 3×, Dynamisch nach Gegnerdruck (siehe RunCamera)
enum CameraZoomMode { NEAR, FAR, DYNAMIC }

var joystick_mode := JoystickMode.FLOATING
var joystick_side := JoystickSide.BOTH
## Deckkraft des Joysticks, 0.2..1.0
var joystick_opacity := 1.0
## Nur Testwert (Debug-Menü), bis der Zoom entschieden ist
var camera_zoom_mode := CameraZoomMode.DYNAMIC
## Nur Testwert (Debug-Menü): Spiel läuft weiter, während das Debug-Menü offen ist
var debug_keep_running := false
## Nur Testwert (Debug-Menü): Nach einem Treffer kurz unverwundbar? Noch nicht entschieden, siehe PLAN.md
var debug_hit_invulnerability := true
## Nur Testwert (Debug-Menü): Dauer der Unverwundbarkeit in Sekunden
var debug_invulnerability_duration := 0.5
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
	var invulnerability: bool = config.get_value("debug", "hit_invulnerability", debug_hit_invulnerability)
	debug_hit_invulnerability = invulnerability
	var duration: float = config.get_value("debug", "invulnerability_duration", debug_invulnerability_duration)
	debug_invulnerability_duration = clampf(duration, MIN_INVULNERABILITY, MAX_INVULNERABILITY)
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
	config.set_value("debug", "hit_invulnerability", debug_hit_invulnerability)
	config.set_value("debug", "invulnerability_duration", debug_invulnerability_duration)
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


func set_debug_hit_invulnerability(enabled: bool) -> void:
	debug_hit_invulnerability = enabled
	_apply()


## persist = false: nur übernehmen, nicht speichern (z. B. während ein Schieberegler gezogen wird)
func set_debug_invulnerability_duration(duration: float, persist := true) -> void:
	debug_invulnerability_duration = clampf(duration, MIN_INVULNERABILITY, MAX_INVULNERABILITY)
	_apply(persist)


func set_show_player_health_bar(show_bar: bool) -> void:
	show_player_health_bar = show_bar
	_apply()


func _apply(persist := true) -> void:
	if persist:
		save_settings()
	changed.emit()
