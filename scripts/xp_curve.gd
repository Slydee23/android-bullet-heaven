class_name XpCurve
extends Resource
## Wie viel Erfahrung der Held für die nächste Stufe braucht (ähnlich Vampire Survivors: schnell am Anfang,
## danach wächst der Bedarf je Stufe um einen festen Betrag, ab bestimmten Stufen um mehr).

## XP von Stufe 1 auf 2
@export var first_level := 5
## Ab welcher Stufe welcher Zuwachs gilt (gleich lang wie increments, aufsteigend sortiert)
@export var increase_from_levels := PackedInt32Array([2, 20, 40])
## Zuwachs des Bedarfs pro Stufe
@export var increments := PackedInt32Array([10, 13, 16])


## XP, die man auf Stufe level sammeln muss, um auf level + 1 zu kommen
func needed_for(level: int) -> int:
	var needed := first_level
	for current in range(2, level + 1):
		needed += _increment_at(current)
	return needed


func _increment_at(level: int) -> int:
	var result := 0
	for k in increase_from_levels.size():
		if level >= increase_from_levels[k]:
			result = increments[k]
	return result
