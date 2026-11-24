class_name RunState
extends RefCounted
## Zustand, der nur während eines Runs gilt (Stufe, Erfahrung; später Welle, Kills, Artefakte …).
## Strikt getrennt vom dauerhaften Spielstand: Nach dem Run wird er verworfen (ab M8 als run.save gespeichert).

## Erfahrung oder Bedarf haben sich geändert (für die XP-Leiste)
signal xp_changed(xp: int, needed: int)
## Der Held ist eine Stufe aufgestiegen (bei mehreren Stufen auf einmal einmal pro Stufe)
signal leveled_up(level: int)
## Die Zahl der Seelen hat sich geändert (Kill, Kauf im Rastplatz-Shop)
signal souls_changed(souls: int)

## So oft darf man im Run die Level-Up-Karten neu würfeln
const START_REROLLS := 3

var curve: XpCurve
var level := 1
## Gesammelte Erfahrung auf der aktuellen Stufe
var xp := 0
## Gesamte Erfahrung dieses Runs (für die Zusammenfassung)
var xp_gained := 0
## Übrige Neu-Würfeln-Versuche für Level-Up-Karten
var rerolls := START_REROLLS
## Startwert der zufälligen Hindernisse (gleicher Wert = gleiche Karte, z. B. beim Fortsetzen)
var map_seed := 0
## Seelen: zählen bei jedem Kill und werden im Rastplatz-Shop für Stat-Boni ausgegeben
var souls := 0
## Alle in diesem Run verdienten Seelen (auch ausgegebene, für die Zusammenfassung am Ende)
var souls_earned := 0
## Fortschritt der Expedition: aktuelle Welle, Zahl der Wellen, besiegte Gegner, Kampfzeit in Sekunden (ohne Rastplätze)
var wave := 0
var wave_total := 0
var kills := 0
var time := 0.0
## Globale Boni dieses Runs (Level-Up-Upgrades für den Helden und alle Waffen; später auch Artefakte).
## Rüstung und Dorf-Upgrades kommen aus dem dauerhaften Spielstand und werden beim Run-Start hier eingetragen.
var stats := StatBlock.new()
## Wie oft jeder Helden-Bonus (UpgradeData.id) gewählt wurde
var hero_upgrade_counts: Dictionary[StringName, int] = {}
## Alle Helden-Boni in Kaufreihenfolge als {id, rarity} (für den Spielstand, RunSave)
var hero_upgrade_log: Array[Dictionary] = []


func _init(xp_curve: XpCurve) -> void:
	curve = xp_curve


func add_souls(amount: int) -> void:
	if amount <= 0:
		return
	souls += amount
	souls_earned += amount
	souls_changed.emit(souls)


## Gibt Seelen aus. Liefert false (und ändert nichts), wenn nicht genug da sind.
func spend_souls(amount: int) -> bool:
	if amount > souls:
		return false
	souls -= amount
	souls_changed.emit(souls)
	return true


## Nimmt einen Helden-Bonus auf (Rastplatz-Shop; früher auch aus dem Level-Up)
func add_hero_upgrade(upgrade: UpgradeData, rarity: int) -> void:
	hero_upgrade_counts[upgrade.id] = hero_upgrade_counts.get(upgrade.id, 0) + 1
	hero_upgrade_log.append({"id": String(upgrade.id), "rarity": rarity})
	stats.add(upgrade.make_modifier(rarity))


func hero_upgrade_count(id: StringName) -> int:
	return hero_upgrade_counts.get(id, 0)


## Wie viele Helden-Boni in diesem Run insgesamt gewählt bzw. gekauft wurden (Shop-Preise steigen damit)
func hero_upgrades_total() -> int:
	var total := 0
	for count in hero_upgrade_counts.values():
		total += count
	return total


## XP für die nächste Stufe
func xp_needed() -> int:
	return curve.needed_for(level)


## Fügt Erfahrung hinzu. Reicht sie für mehrere Stufen, steigt der Held mehrmals auf.
func add_xp(amount: int) -> void:
	xp += amount
	xp_gained += amount
	while xp >= xp_needed():
		xp -= xp_needed()
		level += 1
		leveled_up.emit(level)
	xp_changed.emit(xp, xp_needed())
