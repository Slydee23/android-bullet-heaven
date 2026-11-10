class_name RunCamera
extends Camera2D
## Kamera des Helden. Im dynamischen Modus zoomt sie mit steigendem Gegnerdruck fließend von zoom_near auf zoom_far heraus.
## Innerhalb einer Wave zoomt sie nie wieder herein (sonst „pumpt“ das Bild beim Töten von Gegnern).

## Kamera-Zoom-Stufen: Nah zeigt weniger, Weit mehr Spielwelt
## (32×32-Figuren: Nah = 96, Weit = 64 Bildschirmpixel hoch)
const ZOOM_NEAR := 3.0
const ZOOM_FAR := 2.0
## Wie schnell sich der Zoom dem Ziel nähert (klein = langsam und weich)
const ZOOM_SPEED := 0.4
## Bildschirmwackeln: größter Versatz in Welt-Pixeln (bei Zoom 3× also 12 Bildschirmpixel)
const SHAKE_MAX_OFFSET := 4.0
## Kleinster Versatz, solange es wackelt. Sonst runden leichte Treffer auf 0 Pixel und man sieht nichts.
const SHAKE_MIN_OFFSET := 1.5
## So schnell klingt das Wackeln ab (Stärke pro Sekunde, 1.0 → 0 in ca. 0,3 s)
const SHAKE_DECAY := 3.3

var zoom_near := ZOOM_NEAR
var zoom_far := ZOOM_FAR
## false = fester Zoom (fixed_zoom), true = Zoom folgt dem Gegnerdruck
var dynamic := false
var fixed_zoom := ZOOM_NEAR
## Gegnerdruck 0..1, setzt die Run-Szene (z. B. lebende Gegner im Verhältnis zum Wave-Maximum)
var pressure := 0.0

## Höchster Druck der aktuellen Wave
var _peak := 0.0
## Aktuelle Wackel-Stärke 0..1 (fällt mit der Zeit auf 0)
var _trauma := 0.0


func _process(delta: float) -> void:
	if dynamic:
		_peak = maxf(_peak, clampf(pressure, 0.0, 1.0))
	zoom = zoom.lerp(Vector2.ONE * _target_zoom(), 1.0 - exp(-ZOOM_SPEED * delta))
	_update_shake(delta)


## Lässt das Bild kurz wackeln. strength 0..1, mehrere Treffer kurz hintereinander addieren sich (bis 1).
func shake(strength: float) -> void:
	_trauma = minf(_trauma + strength, 1.0)


func _update_shake(delta: float) -> void:
	if _trauma <= 0.0:
		offset = Vector2.ZERO
		return
	_trauma = maxf(_trauma - SHAKE_DECAY * delta, 0.0)
	# Quadratisch: Starke Treffer wackeln deutlich mehr als schwache
	var amount := lerpf(SHAKE_MIN_OFFSET, SHAKE_MAX_OFFSET, _trauma * _trauma)
	# Ganze Pixel, damit die Pixel-Art scharf bleibt
	offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount)).round()


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
