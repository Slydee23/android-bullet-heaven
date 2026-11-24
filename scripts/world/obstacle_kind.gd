class_name ObstacleKind
extends Resource
## Eine Art Hindernis auf der Karte (Fels, Baum, Baumstumpf, umgestürzter Stamm …), z. B. data/obstacles/rock_large.tres.
## Die Form besteht aus einem oder mehreren Kreisen: ein Fels ist ein Kreis, ein langer Stamm mehrere Kreise hintereinander.
## Kreise statt Physik-Körper: Abstandsprüfungen sind billig und passen zum Rest des Spiels (keine Physik für Gegner).
## Grafik (E0c): ein Streifen mit allen Varianten nebeneinander (gleich große Rahmen). Bäume haben eine Krone, die über
## Held und Gegnern liegt; nur der Stamm blockiert.

@export var id := &""
## Kreise der Form, relativ zum Mittelpunkt: x, y = Versatz, z = Radius (Welt-Pixel)
@export var circles := PackedVector3Array([Vector3(0.0, 0.0, 16.0)])
## Gewicht bei der zufälligen Verteilung (höher = häufiger)
@export var weight := 1.0
## Platzhalter-Farbe, falls keine Grafik gesetzt ist
@export var placeholder_color := Color(0.45, 0.4, 0.36)
## Streifen mit den Varianten (z. B. assets/sprites/obstacles/rock_large.png)
@export var texture: Texture2D
## Zahl der Varianten im Streifen (Rahmenbreite = Breite / variants)
@export_range(1, 8) var variants := 1
## Punkt im Rahmen (Pixel), der auf der Position des Hindernisses liegt (Mitte des Hauptkreises)
@export var anchor := Vector2(32.0, 32.0)
## So viele Pixelzeilen von oben sind Krone: Sie wird über Held und Gegnern gezeichnet (0 = keine Krone)
@export var crown_height := 0


## Größe eines Rahmens im Streifen
func frame_size() -> Vector2:
	if not texture:
		return Vector2.ZERO
	return Vector2(texture.get_width() / float(variants), texture.get_height())


## Größte Ausdehnung der Form vom Mittelpunkt (für Abstände beim Verteilen)
func extent() -> float:
	var result := 0.0
	for c in circles:
		result = maxf(result, Vector2(c.x, c.y).length() + c.z)
	return result
