class_name RunCamera
extends Camera2D
## Kamera des Helden. Im dynamischen Modus zoomt sie mit steigendem Gegnerdruck fließend von zoom_near auf zoom_far heraus.
## Innerhalb einer Wave zoomt sie nie wieder herein (sonst „pumpt“ das Bild beim Töten von Gegnern).

## Kamera-Zoom-Stufen: Nah zeigt weniger, Weit mehr Spielwelt
## (32×32-Figuren: Nah = 96, Weit = 72 Bildschirmpixel hoch)
const ZOOM_NEAR := 3.0
const ZOOM_FAR := 2.25
## Wie schnell sich der Zoom dem Ziel nähert (klein = langsam und weich)
const ZOOM_SPEED := 0.4

var zoom_near := ZOOM_NEAR
var zoom_far := ZOOM_FAR
## false = fester Zoom (fixed_zoom), true = Zoom folgt dem Gegnerdruck
var dynamic := false
var fixed_zoom := ZOOM_NEAR
## Gegnerdruck 0..1, setzt die Run-Szene (z. B. lebende Gegner im Verhältnis zum Wave-Maximum)
var pressure := 0.0

## Höchster Druck der aktuellen Wave
var _peak := 0.0


func _process(delta: float) -> void:
	if dynamic:
		_peak = maxf(_peak, clampf(pressure, 0.0, 1.0))
	zoom = zoom.lerp(Vector2.ONE * _target_zoom(), 1.0 - exp(-ZOOM_SPEED * delta))


## Springt sofort auf den Zielzoom (z. B. beim Run-Start), statt langsam dorthin zu zoomen.
func snap_zoom() -> void:
	zoom = Vector2.ONE * _target_zoom()


func _target_zoom() -> float:
	if dynamic:
		return lerpf(zoom_near, zoom_far, smoothstep(0.0, 1.0, _peak))
	return fixed_zoom


## Neue Wave: Die Kamera zoomt langsam wieder auf zoom_near (ab M7 beim Wave-Start bzw. am Rastplatz).
func reset_wave() -> void:
	_peak = 0.0
