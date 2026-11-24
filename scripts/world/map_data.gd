class_name MapData
extends Resource
## Daten einer Expeditions-Karte (z. B. data/maps/forest.tres). Vorerst nur die Hindernisse: eine feste Grundform
## (wiedererkennbare Orte, immer gleich) plus zufällig verteilte Hindernisse, die jeder Run neu würfelt (Startwert im Spielstand).
## Später kommen Boden, Rand und Biom-Einstellungen dazu (E13: weitere Maps).

## Feste Hindernisse (immer gleich)
@export var fixed: Array[ObstaclePlacement] = []
## Arten für die zufällige Verteilung (nach Gewicht)
@export var random_kinds: Array[ObstacleKind] = []
## So viele zufällige Hindernisse kommen dazu (wenn genug Platz ist)
@export var random_count := 8
## Freier Abstand zwischen zwei Hindernissen (Pixel), damit Gegner und Held überall durchpassen
@export var min_gap := 56.0
## Um die Startposition (Mitte) bleibt dieser Radius frei
@export var center_clear := 190.0
## Abstand zum Kartenrand (Pixel)
@export var edge_margin := 40.0
