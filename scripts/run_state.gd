class_name RunState
extends RefCounted
## Zustand, der nur während eines Runs gilt (Stufe, Erfahrung; später Welle, Kills, Artefakte …).
## Strikt getrennt vom dauerhaften Spielstand: Nach dem Run wird er verworfen (ab M8 als run.save gespeichert).

## Erfahrung oder Bedarf haben sich geändert (für die XP-Leiste)
signal xp_changed(xp: int, needed: int)
## Der Held ist eine Stufe aufgestiegen (bei mehreren Stufen auf einmal einmal pro Stufe)
signal leveled_up(level: int)

var curve: XpCurve
var level := 1
## Gesammelte Erfahrung auf der aktuellen Stufe
var xp := 0
## Globale Boni dieses Runs (Level-Up-Upgrades für den Helden und alle Waffen; später auch Artefakte).
## Rüstung und Dorf-Upgrades kommen aus dem dauerhaften Spielstand und werden beim Run-Start hier eingetragen.
var stats := StatBlock.new()
## Wie oft jeder Helden-Bonus (UpgradeData.id) gewählt wurde
var hero_upgrade_counts: Dictionary[StringName, int] = {}


func _init(xp_curve: XpCurve) -> void:
	curve = xp_curve


## Nimmt einen Helden-Bonus aus dem Level-Up auf
func add_hero_upgrade(upgrade: UpgradeData, rarity: int) -> void:
	hero_upgrade_counts[upgrade.id] = hero_upgrade_counts.get(upgrade.id, 0) + 1
	stats.add(upgrade.make_modifier(rarity))


func hero_upgrade_count(id: StringName) -> int:
	return hero_upgrade_counts.get(id, 0)


## XP für die nächste Stufe
func xp_needed() -> int:
	return curve.needed_for(level)


## Fügt Erfahrung hinzu. Reicht sie für mehrere Stufen, steigt der Held mehrmals auf.
func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_needed():
		xp -= xp_needed()
		level += 1
		leveled_up.emit(level)
	xp_changed.emit(xp, xp_needed())
