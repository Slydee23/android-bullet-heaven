class_name WeaponStatDisplay
extends RefCounted
## Baut die Werte-Zeilen einer Waffe für den Statusbildschirm (Karte und Detailfenster).
## Es erscheinen nur Stats, die die Angriffsart der Waffe versteht (WeaponBehavior.supports_stat).
## Bezeichnungen und Darstellung kann die Angriffsart anpassen (stat_label_key, cooldown_as_rate, is_permanent).

## Alle Werte im Detailfenster: [Stat-ID, Übersetzungsschlüssel der Bezeichnung]
const DETAIL_STATS := [
	[&"damage", "STAT_DAMAGE"],
	[&"cooldown", "STAT_ATTACK_SPEED"],
	[&"duration", "STAT_DURATION"],
	[&"amount", "STAT_AMOUNT"],
	[&"range", "STAT_RANGE"],
	[&"area", "STAT_AREA"],
	[&"fuse", "STAT_FUSE"],
	[&"pierce", "STAT_PIERCE"],
	[&"ricochet", "STAT_RICOCHET"],
	[&"projectile_speed", "STAT_PROJECTILE_SPEED"],
	[&"orbit_speed", "STAT_ORBIT_SPEED"],
]


## Eine Zeile mit den wichtigsten Werten für die Waffenkarte. Welche das sind, legt die Angriffsart fest (card_stats).
static func compact_text(weapon: WeaponInstance, translate: Callable) -> String:
	var parts: Array[String] = []
	if weapon.data.behavior == null:
		return ""
	for stat in weapon.data.behavior.card_stats():
		parts.append(_card_value_text(weapon, stat, translate))
	return " · ".join(parts)


## Alle Werte für das Detailfenster als Liste von [Bezeichnung, Wert]
static func detail_rows(weapon: WeaponInstance, translate: Callable) -> Array:
	var rows := []
	for entry in DETAIL_STATS:
		if _supported(weapon, entry[0]):
			var key: String = weapon.data.behavior.stat_label_key(entry[0], entry[1])
			rows.append([translate.call(key), value_text(weapon, entry[0], translate)])
	return rows


## Wert eines Stats als Text. Tempo wird als Angriffe pro Sekunde gezeigt (Abklingzeit rückwärts), außer die Angriffsart
## zeigt es in Sekunden (Zyklus des Schwerts). Eine Wirkdauer, die den Zyklus erreicht, heißt „Dauerhaft“.
static func value_text(weapon: WeaponInstance, stat: StringName, translate: Callable) -> String:
	return format_value(weapon, stat, weapon.get_stat(stat), translate)


## Bezeichnung eines Stats für diese Waffe (z. B. „Klingen“ statt „Projektile pro Angriff“ beim Schwert)
static func label_key(weapon: WeaponInstance, stat: StringName) -> String:
	var default_key := "STAT_" + String(stat).to_upper()
	for entry in DETAIL_STATS:
		if entry[0] == stat:
			default_key = entry[1]
	if weapon.data.behavior:
		return weapon.data.behavior.stat_label_key(stat, default_key)
	return default_key


## Wie value_text, aber für einen beliebigen Wert (Vorschau „alt → neu“ auf der Level-Up-Karte)
static func format_value(weapon: WeaponInstance, stat: StringName, value: float, translate: Callable) -> String:
	var behavior := weapon.data.behavior
	match stat:
		&"cooldown":
			if behavior and not behavior.cooldown_as_rate():
				return translate.call("STAT_SECONDS") % [_number(value)]
			return translate.call("STAT_PER_SECOND") % [snappedf(1.0 / maxf(value, 0.01), 0.01)]
		&"fuse":
			return translate.call("STAT_SECONDS") % [_number(value)]
		&"duration":
			# Dauerhaft, sobald die Wirkdauer den Zyklus erreicht (nur Waffen mit Zyklus in Sekunden, z. B. das Schwert)
			if behavior and not behavior.cooldown_as_rate() and value >= weapon.get_stat(&"cooldown") - 0.001:
				return translate.call("STAT_PERMANENT")
			return translate.call("STAT_SECONDS") % [_number(value)]
		&"orbit_speed":
			return translate.call("STAT_PER_ROTATION") % [snappedf(value / TAU, 0.01)]
		&"amount", &"pierce", &"ricochet":
			return "×%d" % roundi(value)
		&"damage":
			# Schaden immer ganzzahlig (Prozent-Boni ergeben sonst Kommazahlen wie 70.2)
			return str(roundi(value))
	return str(roundi(value))


## Wie value_text, nur kürzer für die Karte: Die Wirkdauer steht zusammen mit dem Zyklus („3 / 5 s“).
static func _card_value_text(weapon: WeaponInstance, stat: StringName, translate: Callable) -> String:
	var behavior := weapon.data.behavior
	if stat == &"duration" and not behavior.is_permanent(weapon):
		return translate.call("STAT_DURATION_OF_CYCLE") % [_number(weapon.get_stat(&"duration")), _number(weapon.get_stat(&"cooldown"))]
	return value_text(weapon, stat, translate)


## Zahl ohne überflüssige Nachkommastellen („3“, „2.5“)
static func _number(value: float) -> String:
	var snapped := snappedf(value, 0.1)
	if is_equal_approx(snapped, roundf(snapped)):
		return str(roundi(snapped))
	return str(snapped)


static func _supported(weapon: WeaponInstance, stat: StringName) -> bool:
	return weapon.data.behavior != null and weapon.data.behavior.supports_stat(stat)
