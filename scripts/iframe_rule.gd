class_name IFrameRule
extends Resource
## Regel für die Unverwundbarkeit (I-Frames) nach einem Treffer: Schwere Treffer geben mehr Zeit zum Reagieren.
## Formel und Grenzen liegen nur hier. Ein anderer Charakter oder Modus bekommt einfach eine eigene .tres-Datei.

## Kürzeste Dauer in Sekunden, gilt für kleine Treffer
@export var min_duration := 0.2
## Längste Dauer in Sekunden
@export var max_duration := 0.4
## Ab diesem Anteil der maximalen HP gibt ein Treffer die längste Dauer (0.15 = 15 %)
@export var reference_share := 0.15


## damage ist der tatsächlich erlittene Schaden, also nach Abzug von Rüstung.
func duration_for(damage: float, max_hp: float) -> float:
	var longest := maxf(min_duration, max_duration)
	if max_hp <= 0.0 or reference_share <= 0.0:
		return longest
	return clampf(max_duration * (damage / max_hp) / reference_share, min_duration, longest)
