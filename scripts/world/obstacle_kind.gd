class_name ObstacleKind
extends Resource
## Eine Art Hindernis auf der Karte (Fels, Baum, Baumstumpf, umgestürzter Stamm …), z. B. data/obstacles/rock_large.tres.
## Die Form besteht aus einem oder mehreren Kreisen: ein Fels ist ein Kreis, ein langer Stamm mehrere Kreise hintereinander.
## Kreise statt Physik-Körper: Abstandsprüfungen sind billig und passen zum Rest des Spiels (keine Physik für Gegner).
## Grafik folgt in E0c (Fuß unter den Figuren, Krone darüber).

@export var id := &""
## Kreise der Form, relativ zum Mittelpunkt: x, y = Versatz, z = Radius (Welt-Pixel)
@export var circles := PackedVector3Array([Vector3(0.0, 0.0, 16.0)])
## Gewicht bei der zufälligen Verteilung (höher = häufiger)
@export var weight := 1.0
## Platzhalter-Farbe, bis es Grafiken gibt
@export var placeholder_color := Color(0.45, 0.4, 0.36)


## Größte Ausdehnung der Form vom Mittelpunkt (für Abstände beim Verteilen)
func extent() -> float:
	var result := 0.0
	for c in circles:
		result = maxf(result, Vector2(c.x, c.y).length() + c.z)
	return result
