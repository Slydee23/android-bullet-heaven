class_name PickupManager
extends Node2D
## Seelensplitter (XP-Kristalle): Pool in gepackten Arrays, ein Zeichenaufruf für alle, kein Node pro Splitter.
## Kommt der Held mit seinem Sammelradius heran, springen die Splitter kurz zurück und fliegen dann beschleunigend zu ihm.
## Liegen schon MAX_PICKUPS herum, wandert neue Erfahrung in den vom Helden am weitesten entfernten Splitter (er wird größer).

## Ein Splitter wurde eingesammelt (die Run-Szene gibt die Erfahrung an den RunState)
signal collected(value: int)

## Höchstzahl gleichzeitig liegender Splitter, darüber verschmelzen sie (Leistung und Übersicht)
const MAX_PICKUPS := 400
const TEXTURE := preload("res://assets/sprites/pickups/xp_crystal.png")
## Aufbau des Spritesheets: eine Zeile je Größe (klein, mittel, groß), 4 Frames à 16×16, Spitze unten bei FOOT
const FRAME_SIZE := Vector2(16.0, 16.0)
const FRAMES := 4
const FOOT := Vector2(7.0, 14.0)
const ANIMATION_FPS := 5.0
## Ab diesem Wert ist ein Splitter mittel (grün) bzw. groß (violett)
const MEDIUM_FROM := 3
const LARGE_FROM := 10
## Eingesammelt, sobald der Splitter so nah an den Füßen des Helden ist (Welt-Pixel)
const COLLECT_DISTANCE := 8.0
## Anfangstempo beim Losfliegen: negativ = erst ein kurzer Sprung weg vom Helden
const FLY_START_SPEED := -90.0
const FLY_ACCELERATION := 1100.0
const FLY_MAX_SPEED := 700.0

## Wer einsammelt (setzt die Run-Szene)
var target: Player
var count := 0

var _positions := PackedVector2Array()
var _values := PackedInt32Array()
## 1 = fliegt zum Helden, 0 = liegt
var _flying := PackedByteArray()
var _speeds := PackedFloat32Array()
var _anim_offsets := PackedFloat32Array()
var _time := 0.0


func _ready() -> void:
	_positions.resize(MAX_PICKUPS)
	_values.resize(MAX_PICKUPS)
	_flying.resize(MAX_PICKUPS)
	_speeds.resize(MAX_PICKUPS)
	_anim_offsets.resize(MAX_PICKUPS)


## Legt einen Splitter mit value Erfahrung an pos ab (Füße des gestorbenen Gegners)
func spawn(pos: Vector2, value: int) -> void:
	if value <= 0:
		return
	if count >= MAX_PICKUPS:
		_values[_farthest_lying()] += value
		return
	_positions[count] = pos
	_values[count] = value
	_flying[count] = 0
	_speeds[count] = 0.0
	_anim_offsets[count] = randf() * 10.0
	count += 1


## Alle liegenden Splitter fliegen zum Helden (Debug „Alle Splitter anziehen“, später ein Magnet-Fund)
func attract_all() -> void:
	for i in count:
		if not _flying[i]:
			_flying[i] = 1
			_speeds[i] = FLY_START_SPEED


func remove_all() -> void:
	count = 0


## Größe eines Splitters: 0 klein, 1 mittel, 2 groß
static func tier_of(value: int) -> int:
	if value >= LARGE_FROM:
		return 2
	if value >= MEDIUM_FROM:
		return 1
	return 0


func get_value(i: int) -> int:
	return _values[i]


## Der liegende Splitter, der am weitesten vom Helden entfernt ist (nimmt beim Verschmelzen die neue Erfahrung auf).
## Läuft über alle Splitter, aber nur wenn die Höchstzahl erreicht ist.
func _farthest_lying() -> int:
	var hero := target.global_position if target else Vector2.ZERO
	var best := 0
	var best_sq := -1.0
	for i in count:
		if _flying[i]:
			continue
		var distance_sq := hero.distance_squared_to(_positions[i])
		if distance_sq > best_sq:
			best_sq = distance_sq
			best = i
	return best


func _process(delta: float) -> void:
	_time += delta
	if target and count > 0:
		_update(delta)
	queue_redraw()


func _update(delta: float) -> void:
	var hero := target.global_position
	var radius_sq := target.pickup_radius * target.pickup_radius
	# Rückwärts, weil beim Einsammeln der letzte Splitter auf den freien Platz rückt
	for i in range(count - 1, -1, -1):
		var pos := _positions[i]
		var distance_sq := pos.distance_squared_to(hero)
		if not _flying[i]:
			if distance_sq > radius_sq:
				continue
			_flying[i] = 1
			_speeds[i] = FLY_START_SPEED
		var speed := minf(_speeds[i] + FLY_ACCELERATION * delta, FLY_MAX_SPEED)
		_speeds[i] = speed
		var distance := sqrt(distance_sq)
		var step := speed * delta
		if distance <= COLLECT_DISTANCE or step >= distance:
			_collect(i)
			continue
		_positions[i] = pos + (hero - pos) / distance * step


func _collect(i: int) -> void:
	var value := _values[i]
	count -= 1
	if i != count:
		_positions[i] = _positions[count]
		_values[i] = _values[count]
		_flying[i] = _flying[count]
		_speeds[i] = _speeds[count]
		_anim_offsets[i] = _anim_offsets[count]
	collected.emit(value)


func _draw() -> void:
	for i in count:
		var phase := _time + _anim_offsets[i]
		var frame := int(phase * ANIMATION_FPS) % FRAMES
		# Liegende Splitter schweben sanft einen Pixel auf und ab
		var bob := -1.0 if not _flying[i] and int(phase * 1.5) % 2 == 0 else 0.0
		var source := Rect2(Vector2(frame * FRAME_SIZE.x, tier_of(_values[i]) * FRAME_SIZE.y), FRAME_SIZE)
		var top_left := (_positions[i] - FOOT + Vector2(0.0, bob)).round()
		draw_texture_rect_region(TEXTURE, Rect2(top_left, FRAME_SIZE), source)
