class_name AuraDrawer
extends Node2D
## Zeichnet alle Auren (z. B. den Flammenring der Flammenfackel) in einem einzigen _draw.
## Liegt in der Run-Szene vor dem EnemyManager, also am Boden unter Gegnern und Held.
## Eine Aura besteht aus einem schwachen Glutkreis und kleinen Flammen am Rand. Die Flammen sind einzelne Bilder
## (WeaponData.projectile_texture), nicht vergrößert: So bleibt der Ring bei jedem Radius pixelscharf.
## Regel für die Flammen-Grafik: Der Bildinhalt liegt mittig im Frame, denn die Bildmitte steht auf der Ringlinie.

## Abstand der Flammen auf dem Ring in Welt-Pixeln
const FLAME_SPACING := 14.0
## So schnell dreht sich der Ring (Bogenmaß pro Sekunde)
const SPIN_SPEED := 0.25
const GLOW_COLOR := Color(1.0, 0.42, 0.12, 0.08)
const RIM_COLOR := Color(1.0, 0.55, 0.2, 0.18)
const RIM_WIDTH := 2.0
## Der Ring liegt um die Körpermitte des Helden (wie die kreisenden Klingen), nicht um seine Füße.
## Treffer rechnen weiter von Fuß zu Fuß: Held und Gegner sind gleich hoch versetzt, die Abstände bleiben also gleich.
const BODY_HEIGHT := Player.BODY_CENTER_HEIGHT

var _weapons: Array[WeaponInstance] = []
var _centers: Array[Node2D] = []
var _time := 0.0


## Aura einer Waffe anmelden: Sie folgt center (dem Helden).
func add(weapon: WeaponInstance, center: Node2D) -> void:
	if weapon in _weapons:
		return
	_weapons.append(weapon)
	_centers.append(center)


func _process(delta: float) -> void:
	if _weapons.is_empty():
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	for w in _weapons.size():
		var weapon := _weapons[w]
		var center := _centers[w].global_position - global_position - Vector2(0.0, BODY_HEIGHT)
		var radius := weapon.get_stat(&"range")
		draw_circle(center, radius, GLOW_COLOR)
		draw_arc(center, radius, 0.0, TAU, 64, RIM_COLOR, RIM_WIDTH)
		var texture := weapon.data.projectile_texture
		if not texture:
			continue
		var frame_width := weapon.data.frame_width
		var frame_size := Vector2(frame_width, texture.get_height())
		var frames := maxi(1, int(texture.get_width() / float(frame_width)))
		var tick := int(_time * weapon.data.animation_fps)
		var flames := maxi(8, int(TAU * radius / FLAME_SPACING))
		for k in flames:
			var point := center + Vector2.from_angle(TAU * k / flames + _time * SPIN_SPEED) * radius
			# Die Bildmitte der Flamme liegt auf der Ringlinie (der Bildinhalt ist im Frame zentriert), auf ganze Pixel
			# gerundet (sonst flimmert sie beim Drehen)
			var top_left := (point - frame_size * 0.5).round()
			# Jede Flamme startet in einem anderen Frame, damit der Ring unregelmäßig flackert
			var frame := (tick + k * 3) % frames
			draw_texture_rect_region(texture, Rect2(top_left, frame_size), Rect2(Vector2(frame * frame_width, 0), frame_size))
