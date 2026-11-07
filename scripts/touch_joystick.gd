class_name TouchJoystick
extends Control
## Virtueller Touch-Joystick: Floating oder fest, auf der linken, rechten oder beiden Bildschirmseiten
## (siehe Settings.JoystickMode und Settings.JoystickSide).
## Liefert die Laufrichtung in `output` (Länge 0..1).

const RING_TEXTURE := preload("res://assets/ui/joystick_ring.png")
const KNOB_TEXTURE := preload("res://assets/ui/joystick_knob.png")

## Vergrößerung der Joystick-Texturen (Ring 32 px → 192 px)
const SCALE := 6
## Abstand des festen Joysticks von der unteren Bildschirmecke
const FIXED_MARGIN := Vector2(80, 80)
## Unterhalb dieses Anteils des Radius bleibt der Held stehen
const DEADZONE := 0.15
## Durchsichtigkeit des festen Joysticks, solange er nicht berührt wird
const IDLE_ALPHA := 0.5

## Laufrichtung, Länge 0..1
var output := Vector2.ZERO

var _touch_index := -1
var _center := Vector2.ZERO
var _knob_offset := Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Settings.changed.connect(_release)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and _can_start_at(event.position):
			_touch_index = event.index
			_center = _fixed_center() if Settings.joystick_mode == Settings.JoystickMode.FIXED else event.position
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_release()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)


func _can_start_at(pos: Vector2) -> bool:
	if Settings.joystick_mode == Settings.JoystickMode.FIXED:
		# Etwas großzügiger als der Ring, damit man ihn leicht trifft
		return pos.distance_to(_fixed_center()) < _radius() * 1.5
	match Settings.joystick_side:
		Settings.JoystickSide.LEFT:
			return pos.x < size.x * 0.5
		Settings.JoystickSide.RIGHT:
			return pos.x >= size.x * 0.5
	return true  # BOTH


func _update_knob(touch_pos: Vector2) -> void:
	var radius := _radius()
	_knob_offset = (touch_pos - _center).limit_length(radius)
	var strength := _knob_offset.length() / radius
	output = Vector2.ZERO if strength < DEADZONE else _knob_offset / radius
	queue_redraw()


func _release() -> void:
	_touch_index = -1
	_knob_offset = Vector2.ZERO
	output = Vector2.ZERO
	queue_redraw()


func _radius() -> float:
	return RING_TEXTURE.get_width() * SCALE * 0.5


func _fixed_center() -> Vector2:
	var y := size.y - FIXED_MARGIN.y - _radius()
	if Settings.joystick_side == Settings.JoystickSide.RIGHT:
		return Vector2(size.x - FIXED_MARGIN.x - _radius(), y)
	return Vector2(FIXED_MARGIN.x + _radius(), y)


func _draw() -> void:
	var active := _touch_index != -1
	var center := _center
	var alpha := Settings.joystick_opacity
	if not active:
		if Settings.joystick_mode != Settings.JoystickMode.FIXED:
			return  # Floating: nur sichtbar, solange der Daumen drauf ist
		center = _fixed_center()
		alpha *= IDLE_ALPHA
	var ring_size := RING_TEXTURE.get_size() * SCALE
	var knob_size := KNOB_TEXTURE.get_size() * SCALE
	var tint := Color(1, 1, 1, alpha)
	draw_texture_rect(RING_TEXTURE, Rect2(center - ring_size * 0.5, ring_size), false, tint)
	draw_texture_rect(KNOB_TEXTURE, Rect2(center + _knob_offset - knob_size * 0.5, knob_size), false, tint)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
