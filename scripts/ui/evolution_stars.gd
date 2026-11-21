class_name EvolutionStars
extends Control
## Entwicklungsstufe einer Waffe als kleine Sterne: so viele Sterne wie die Waffe Stufen hat, erreichte sind gold.

const STAR_SIZE := 30.0
const GAP := 2.0
const FILLED := Color("#f9c769")
const FILLED_EDGE := Color("#a45b30")
const EMPTY := Color("#332930")
const EMPTY_EDGE := Color("#8a6e52")

var stars := 3:
	set(value):
		stars = maxi(value, 0)
		custom_minimum_size = Vector2(stars * (STAR_SIZE + GAP) - GAP, STAR_SIZE)
		queue_redraw()
var reached := 0:
	set(value):
		reached = value
		queue_redraw()

var _outer := PackedVector2Array()
var _inner := PackedVector2Array()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(stars * (STAR_SIZE + GAP) - GAP, STAR_SIZE)
	_outer = _star(STAR_SIZE * 0.5, STAR_SIZE * 0.24)
	_inner = _star(STAR_SIZE * 0.5 - 3.5, STAR_SIZE * 0.24 - 1.6)


func _draw() -> void:
	for i in stars:
		var center := Vector2(i * (STAR_SIZE + GAP) + STAR_SIZE * 0.5, STAR_SIZE * 0.5 + 0.5)
		var filled := i < reached
		draw_set_transform(center)
		draw_colored_polygon(_outer, FILLED_EDGE if filled else EMPTY_EDGE)
		draw_colored_polygon(_inner, FILLED if filled else EMPTY)
	draw_set_transform(Vector2.ZERO)


## Fünfzackiger Stern um (0, 0), Spitze nach oben
static func _star(outer: float, inner: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for k in 10:
		var radius := outer if k % 2 == 0 else inner
		points.append(Vector2.from_angle(-PI * 0.5 + k * PI / 5.0) * radius)
	return points
