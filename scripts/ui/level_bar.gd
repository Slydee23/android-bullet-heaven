class_name LevelBar
extends Control
## Level-Leiste einer Waffe: 10 kleine Felder, so viele gefüllt wie das Waffenlevel.

const MAX_LEVEL := 10
const CELL := Vector2(16.0, 16.0)
const GAP := 4.0
const FILLED := Color("#f9c769")
const FILLED_EDGE := Color("#a45b30")
const EMPTY := Color("#332930")
const EMPTY_EDGE := Color("#0c0d0f")

var level := 1:
	set(value):
		level = clampi(value, 0, MAX_LEVEL)
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(MAX_LEVEL * (CELL.x + GAP) - GAP, CELL.y)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	for i in MAX_LEVEL:
		var rect := Rect2(Vector2(i * (CELL.x + GAP), 0.0), CELL)
		var filled := i < level
		draw_rect(rect, FILLED_EDGE if filled else EMPTY_EDGE)
		draw_rect(rect.grow(-3.0), FILLED if filled else EMPTY)
