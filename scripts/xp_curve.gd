class_name XpCurve
extends Resource
## Wie viel Erfahrung der Held für die nächste Stufe braucht (ähnlich Vampire Survivors: schnell am Anfang,
## danach wächst der Bedarf je Stufe um einen festen Betrag, ab bestimmten Stufen um mehr).

## XP von Stufe 1 auf 2
@export var first_level := 9
## Ab welcher Stufe welcher Zuwachs gilt (gleich lang wie increments, aufsteigend sortiert)
@export var increase_from_levels := PackedInt32Array([2, 10, 20])
## Zuwachs des Bedarfs pro Stufe
@export var increments := PackedInt32Array([5, 9, 14])
## Zusätzliches Wachstum je Stufe in Prozent (0.03 = +3 % pro Stufe, wirkt auf den Gesamtbedarf). Hält die Level-Ups
## in späten Wellen im Takt, wenn Gegner dort viel mehr Erfahrung geben.
@export var growth := 0.03


## XP, die man auf Stufe level sammeln muss, um auf level + 1 zu kommen
func needed_for(level: int) -> int:
	var needed := first_level
	for current in range(2, level + 1):
		needed += _increment_at(current)
	return roundi(needed * pow(1.0 + growth, level - 1))


func _increment_at(level: int) -> int:
	var result := 0
	for k in increase_from_levels.size():
		if level >= increase_from_levels[k]:
			result = increments[k]
	return result
