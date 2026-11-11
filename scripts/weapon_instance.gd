class_name WeaponInstance
extends RefCounted
## Eine Waffe im laufenden Run: Datendatei plus Zustand (Level, Abklingzeit, später Upgrades und zusätzliche Effekte).

var data: WeaponData
var level := 1
## Sekunden bis zum nächsten Angriff
var cooldown_left := 0.0
## Effekte, die erst im Run dazukommen (z. B. durch ein Level-Up-Upgrade), zusätzlich zu data.effects
var extra_effects: Array[WeaponEffect] = []


func _init(weapon_data: WeaponData) -> void:
	data = weapon_data


## Fertiger Wert eines Stats. In M4 der Grundwert aus der Datendatei,
## ab M6 rechnet hier das Werte-System (Modifikatoren, Spieler-Stats, Artefakte).
func get_stat(stat: StringName) -> float:
	var value: float = data.base_stats.get(stat, 0.0)
	return value
