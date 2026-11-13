class_name WeaponBehavior
extends Resource
## Basis für Angriffsarten („wie greift die Waffe an“): Geschoss, kreisende Klinge, Aura, Einschläge, Schläge …
## Neue Angriffsart = neues Skript, das von dieser Klasse erbt. Viele Waffen können dieselbe Angriffsart nutzen.
## Eine Behavior-Datei wird von allen Waffen geteilt, die sie nutzen: Zustand gehört in die WeaponInstance, nicht hierher.

## Stats, die jede Angriffsart versteht
const COMMON_STATS: Array[StringName] = [&"damage", &"cooldown", &"range"]


## Löst einen Angriff aus, wenn die Abklingzeit abgelaufen ist. true = Angriff ausgelöst (Abklingzeit startet),
## false = kein Ziel in Reichweite (die Waffe bleibt schussbereit).
func fire(_weapon: WeaponInstance, _context: WeaponContext) -> bool:
	return false


## Jeden Frame, für Dauerwaffen (kreisende Klinge, Aura). Standard: nichts.
func tick(_weapon: WeaponInstance, _context: WeaponContext, _delta: float) -> void:
	pass


## Die Werte der Waffe haben sich geändert (z. B. Upgrade): Dauerwaffen bauen sich hier neu auf. Standard: nichts.
func on_stats_changed(_weapon: WeaponInstance, _context: WeaponContext) -> void:
	pass


## Die wichtigsten Werte dieser Angriffsart für die Waffenkarte im Statusbildschirm (eine kurze Zeile).
## Jede Angriffsart wählt eigene, z. B. eine Aura Schaden, Treffer pro Sekunde und Radius.
func card_stats() -> Array[StringName]:
	return [&"damage", &"cooldown"]


## Übersetzungsschlüssel der Bezeichnung eines Stats im Statusbildschirm. Angriffsarten können eigene Namen wählen
## (z. B. „Klingen“ statt „Projektile pro Angriff“). Standard: default_key.
func stat_label_key(_stat: StringName, default_key: String) -> String:
	return default_key


## Wird die Abklingzeit als „Angriffe pro Sekunde“ gezeigt (true) oder in Sekunden (false, z. B. der Zyklus des Schwerts)?
func cooldown_as_rate() -> bool:
	return true


## Ist die Waffe dauerhaft aktiv (z. B. Klingen, deren Wirkdauer den Zyklus erreicht)? Standard: nein.
func is_permanent(_weapon: WeaponInstance) -> bool:
	return false


## Letzte Grenze eines fertigen Werts, die von anderen Werten abhängt (z. B. Wirkdauer höchstens so lang wie der Zyklus).
## Feste Grenzen stehen in WeaponData.stat_limits. Standard: unverändert.
func limit_stat(_weapon: WeaponInstance, _stat: StringName, value: float) -> float:
	return value


## Hat dieser Stat bei dieser Angriffsart eine Wirkung? Der Level-Up-Pool (M6) bietet nur Upgrades für unterstützte Stats an
## (z. B. keine „+1 Projektil“ für eine Aura).
func supports_stat(stat: StringName) -> bool:
	return stat in COMMON_STATS
