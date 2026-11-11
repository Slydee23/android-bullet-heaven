class_name WeaponInstance
extends RefCounted
## Eine Waffe im laufenden Run: Datendatei plus Zustand (Level, Abklingzeit, Zielwahl, später Upgrades und zusätzliche Effekte).

## Werte haben sich geändert (Upgrade, Debug-Bonus): Dauerwaffen bauen sich daraufhin neu auf.
signal stats_changed

var data: WeaponData
var level := 1
## Sekunden bis zum nächsten Angriff
var cooldown_left := 0.0
## Wie die Waffe ihre Ziele wählt. Eigene Kopie, damit ein Upgrade sie austauschen kann, ohne die Datendatei zu ändern.
var target_picker: TargetPicker
## Effekte, die erst im Run dazukommen (z. B. durch ein Level-Up-Upgrade), zusätzlich zu data.effects
var extra_effects: Array[WeaponEffect] = []

## Feste Boni je Stat (einfachste Vorstufe der Modifikatoren, ab M6 rechnet das Werte-System)
var _flat_bonus: Dictionary[StringName, float] = {}


func _init(weapon_data: WeaponData) -> void:
	data = weapon_data
	if data.target_picker:
		target_picker = data.target_picker.duplicate() as TargetPicker
	else:
		target_picker = NearestDistinctPicker.new()


## Fertiger Wert eines Stats. Heute: Grundwert aus der Datendatei plus feste Boni.
## Ab M6 rechnet hier das Werte-System (Modifikatoren, Spieler-Stats, Artefakte).
func get_stat(stat: StringName) -> float:
	var base: float = data.base_stats.get(stat, 0.0)
	return base + _flat_bonus.get(stat, 0.0)


func add_flat(stat: StringName, value: float) -> void:
	_flat_bonus[stat] = _flat_bonus.get(stat, 0.0) + value
	stats_changed.emit()


func reset_bonuses() -> void:
	_flat_bonus.clear()
	stats_changed.emit()
