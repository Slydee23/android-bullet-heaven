class_name OptionsCatalog
extends RefCounted
## Einzige Stelle, an der Kategorien und Optionen des Optionsmenüs festgelegt werden.
## - Neue Kategorie: Zeile in CATEGORIES ergänzen (Reihenfolge = Reiter-Reihenfolge).
## - Option verschieben: ihre Kategorie-ID ändern. Option entfernen: ihre Zeile löschen.
## - Neue Option: Zeile in options() ergänzen, dazu die Eigenschaft (Laden/Speichern) in scripts/core/settings.gd.
## Kategorien ohne Optionen werden automatisch ausgeblendet.

const CATEGORIES := [
	[&"controls", "OPTIONS_SECTION_CONTROLS"],
	[&"display", "OPTIONS_SECTION_DISPLAY"],
	[&"graphics", "OPTIONS_SECTION_GRAPHICS"],
	[&"audio", "OPTIONS_SECTION_AUDIO"],
	[&"general", "OPTIONS_SECTION_GENERAL"],
]


static func options() -> Array[OptionDef]:
	return [
		# Steuerung
		OptionDef.choice(&"controls", "OPTIONS_JOYSTICK_MODE", &"joystick_mode", [
			[Settings.JoystickMode.FLOATING, "OPTIONS_JOYSTICK_FLOATING"],
			[Settings.JoystickMode.FIXED, "OPTIONS_JOYSTICK_FIXED"],
		]),
		OptionDef.choice(&"controls", "OPTIONS_JOYSTICK_SIDE", &"joystick_side", [
			[Settings.JoystickSide.LEFT, "OPTIONS_SIDE_LEFT"],
			[Settings.JoystickSide.RIGHT, "OPTIONS_SIDE_RIGHT"],
			[Settings.JoystickSide.BOTH, "OPTIONS_SIDE_BOTH"],
		], _is_side_disabled),
		OptionDef.slider(&"controls", "OPTIONS_JOYSTICK_OPACITY", &"joystick_transparency",
				0.0, (1.0 - Settings.MIN_JOYSTICK_OPACITY) * 100.0, 5.0, "%d %%"),
		OptionDef.toggle(&"controls", "OPTIONS_VIBRATION", &"vibration"),
		# Anzeige
		OptionDef.choice(&"display", "OPTIONS_CAMERA_DISTANCE", &"camera_distance", [
			[Settings.CameraDistance.NEAR, "OPTIONS_CAMERA_NEAR"],
			[Settings.CameraDistance.NORMAL, "OPTIONS_CAMERA_NORMAL"],
			[Settings.CameraDistance.FAR, "OPTIONS_CAMERA_FAR"],
		]),
		OptionDef.toggle(&"display", "OPTIONS_PLAYER_HEALTH_BAR", &"show_player_health_bar"),
		OptionDef.toggle(&"display", "OPTIONS_ENEMY_HEALTH_BARS", &"show_enemy_health_bars"),
		OptionDef.toggle(&"display", "OPTIONS_DAMAGE_NUMBERS", &"show_damage_numbers"),
		OptionDef.toggle(&"display", "OPTIONS_SCREEN_SHAKE", &"screen_shake"),
	]


## Ein fester Joystick braucht eine eindeutige Seite: „Beide“ geht nur bei Floating.
static func _is_side_disabled(value: Variant) -> bool:
	return value == Settings.JoystickSide.BOTH and Settings.joystick_mode == Settings.JoystickMode.FIXED
