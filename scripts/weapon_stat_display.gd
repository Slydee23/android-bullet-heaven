class_name WeaponStatDisplay
extends RefCounted
## Baut die Werte-Zeilen einer Waffe für den Statusbildschirm (Karte und Detailfenster).
## Es erscheinen nur Stats, die die Angriffsart der Waffe versteht (WeaponBehavior.supports_stat).

## Alle Werte im Detailfenster: [Stat-ID, Übersetzungsschlüssel der Bezeichnung]
const DETAIL_STATS := [
	[&"damage", "STAT_DAMAGE"],
	[&"cooldown", "STAT_ATTACK_SPEED"],
	[&"amount", "STAT_AMOUNT"],
	[&"range", "STAT_RANGE"],
	[&"pierce", "STAT_PIERCE"],
	[&"projectile_speed", "STAT_PROJECTILE_SPEED"],
]


## Eine Zeile mit den wichtigsten Werten für die Waffenkarte. Welche das sind, legt die Angriffsart fest (card_stats).
static func compact_text(weapon: WeaponInstance, translate: Callable) -> String:
	var parts: Array[String] = []
	if weapon.data.behavior == null:
		return ""
	for stat in weapon.data.behavior.card_stats():
		parts.append(value_text(weapon, stat, translate))
	return " · ".join(parts)


## Alle Werte für das Detailfenster als Liste von [Bezeichnung, Wert]
static func detail_rows(weapon: WeaponInstance, translate: Callable) -> Array:
	var rows := []
	for entry in DETAIL_STATS:
		if _supported(weapon, entry[0]):
			rows.append([translate.call(entry[1]), value_text(weapon, entry[0], translate)])
	return rows


## Wert eines Stats als Text. Tempo wird als Angriffe pro Sekunde gezeigt (Abklingzeit rückwärts).
static func value_text(weapon: WeaponInstance, stat: StringName, translate: Callable) -> String:
	var value := weapon.get_stat(stat)
	match stat:
		&"cooldown":
			return translate.call("STAT_PER_SECOND") % [snappedf(1.0 / maxf(value, 0.01), 0.01)]
		&"amount", &"pierce":
			return "×%d" % roundi(value)
		&"damage":
			return str(snappedf(value, 0.1))
	return str(roundi(value))


static func _supported(weapon: WeaponInstance, stat: StringName) -> bool:
	return weapon.data.behavior != null and weapon.data.behavior.supports_stat(stat)
