class_name ObstacleDrawer
extends Node2D
## Zeichnet die Hindernisse aus ihren Streifen (ein _draw für alle, gleiche Streifen werden gebündelt).
## Zwei Ebenen, je ein eigener Knoten:
## - BASE (unter Held und Gegnern): Felsen, Stümpfe, Stämme und bei Bäumen alles unterhalb der Krone.
## - CROWN (über Held und Gegnern): nur die Baumkronen. Steht der Held darunter, werden sie halb durchsichtig.
## Die Boden-Ebene ist statisch (einmal gezeichnet). Die Kronen-Ebene zeichnet nur neu, wenn sich eine Durchsichtigkeit ändert.

enum Layer { BASE, CROWN }

const OUTLINE_DARKEN := 0.45
const HIGHLIGHT_LIGHTEN := 0.18
## Durchsichtigkeit einer Krone, unter der der Held steht
const CROWN_FADED_ALPHA := 0.4
## Wie schnell eine Krone aus- und wieder einblendet (Alpha pro Sekunde)
const CROWN_FADE_SPEED := 4.0
## So weit um die Krone herum blendet sie schon aus (der Held soll nicht erst halb verdeckt sein)
const CROWN_MARGIN := 12.0

var layer := Layer.BASE
## Für die Kronen-Ebene: wessen Position die Kronen ausblendet
var hero: Node2D
var obstacles: ObstacleMap:
	set(value):
		obstacles = value
		_crown_alpha.resize(obstacles.count() if obstacles else 0)
		_crown_alpha.fill(1.0)
		set_process(layer == Layer.CROWN and _has_crowns())
		queue_redraw()

var _crown_alpha := PackedFloat32Array()


func _ready() -> void:
	set_process(layer == Layer.CROWN and _has_crowns())


func _has_crowns() -> bool:
	if not obstacles:
		return false
	for kind in obstacles.kinds:
		if kind.texture and kind.crown_height > 0:
			return true
	return false


func _process(delta: float) -> void:
	if not hero:
		return
	var hero_pos := hero.global_position
	var changed := false
	for k in obstacles.count():
		var kind := obstacles.kinds[k]
		if not kind.texture or kind.crown_height <= 0:
			continue
		var target := CROWN_FADED_ALPHA if _crown_rect(k).grow(CROWN_MARGIN).has_point(hero_pos) else 1.0
		var alpha := move_toward(_crown_alpha[k], target, CROWN_FADE_SPEED * delta)
		if alpha != _crown_alpha[k]:
			_crown_alpha[k] = alpha
			changed = true
	if changed:
		queue_redraw()


## Bereich der Krone in der Welt
func _crown_rect(k: int) -> Rect2:
	var kind := obstacles.kinds[k]
	var top_left := (obstacles.positions[k] - kind.anchor).round()
	return Rect2(top_left, Vector2(kind.frame_size().x, kind.crown_height))


func _draw() -> void:
	if not obstacles:
		return
	if layer == Layer.BASE:
		_draw_placeholders()
	for k in obstacles.count():
		var kind := obstacles.kinds[k]
		if not kind.texture:
			continue
		var frame := kind.frame_size()
		var top_left := (obstacles.positions[k] - kind.anchor).round()
		var source_x := obstacles.variants[k] * frame.x
		var crown := mini(kind.crown_height, int(frame.y))
		if layer == Layer.BASE:
			var region := Rect2(source_x, crown, frame.x, frame.y - crown)
			draw_texture_rect_region(kind.texture, Rect2(top_left + Vector2(0.0, crown), region.size), region)
		elif crown > 0:
			var region := Rect2(source_x, 0.0, frame.x, crown)
			draw_texture_rect_region(kind.texture, Rect2(top_left, region.size), region, Color(1.0, 1.0, 1.0, _crown_alpha[k]))


## Arten ohne Grafik bleiben Platzhalter-Kreise
func _draw_placeholders() -> void:
	for k in obstacles.centers.size():
		var kind := obstacles.kinds[obstacles.circle_kind[k]]
		if kind.texture:
			continue
		var color := kind.placeholder_color
		var center := obstacles.centers[k]
		var radius := obstacles.radii[k]
		draw_circle(center, radius, color.darkened(OUTLINE_DARKEN))
		draw_circle(center, radius - 2.0, color)
		draw_circle(center - Vector2(radius, radius) * 0.3, radius * 0.35, color.lightened(HIGHLIGHT_LIGHTEN))
