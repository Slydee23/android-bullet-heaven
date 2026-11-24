class_name ObstacleDrawer
extends Node2D
## Zeichnet die Hindernisse (vorerst als Platzhalter-Kreise in der Farbe der Art, E0c bringt die Grafiken).
## Statisch: wird nur einmal gezeichnet (queue_redraw nach dem Aufbau), kostet danach nichts mehr.

const OUTLINE_DARKEN := 0.45
const HIGHLIGHT_LIGHTEN := 0.18

var obstacles: ObstacleMap:
	set(value):
		obstacles = value
		queue_redraw()


func _draw() -> void:
	if not obstacles:
		return
	for k in obstacles.centers.size():
		var kind := obstacles.kinds[obstacles.circle_kind[k]]
		var color := kind.placeholder_color
		var center := obstacles.centers[k]
		var radius := obstacles.radii[k]
		draw_circle(center, radius, color.darkened(OUTLINE_DARKEN))
		draw_circle(center, radius - 2.0, color)
		draw_circle(center - Vector2(radius, radius) * 0.3, radius * 0.35, color.lightened(HIGHLIGHT_LIGHTEN))
