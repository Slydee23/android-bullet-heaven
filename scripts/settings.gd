extends Node
## Spieler-Einstellungen (Autoload "Settings"): werden in user://settings.cfg gespeichert.

signal changed

enum JoystickMode { FLOATING, FIXED }
## Bildschirmseite, auf der der Joystick startet. Fester Joystick bei BOTH: unten links.
enum JoystickSide { LEFT, RIGHT, BOTH }

const PATH := "user://settings.cfg"
## Erhöhen, wenn sich das Dateiformat ändert (alte Dateien lassen sich dann umwandeln)
const FILE_VERSION := 1
const MIN_JOYSTICK_OPACITY := 0.2

var joystick_mode := JoystickMode.FLOATING
var joystick_side := JoystickSide.BOTH
## Deckkraft des Joysticks, 0.2..1.0
var joystick_opacity := 1.0


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
	var opacity: float = config.get_value("controls", "joystick_opacity", joystick_opacity)
	joystick_opacity = clampf(opacity, MIN_JOYSTICK_OPACITY, 1.0)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("meta", "version", FILE_VERSION)
	config.set_value("controls", "joystick_mode", joystick_mode)
	config.set_value("controls", "joystick_side", joystick_side)
	config.set_value("controls", "joystick_opacity", joystick_opacity)
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


func set_joystick_opacity(opacity: float) -> void:
	joystick_opacity = clampf(opacity, MIN_JOYSTICK_OPACITY, 1.0)
	_apply()


func _apply() -> void:
	save_settings()
	changed.emit()
