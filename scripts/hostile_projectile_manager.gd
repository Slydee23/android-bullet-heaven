class_name HostileProjectileManager
extends Node2D
## Geschosse der Gegner (z. B. Feuerbälle der Kultisten): Pool in gepackten Arrays, ein Zeichenaufruf, kein Node pro Geschoss.
## Sie fliegen gerade (nicht zielsuchend, also ausweichbar), treffen nur den Helden und verpuffen mit einem Einschlag-Effekt,
## wenn sie treffen, ihre Lebenszeit abläuft oder die Arena verlassen.
## Werte und Grafik kommen von der Fähigkeit, die geschossen hat (RangedAbility).

const MAX_SHOTS := 256
## Geschosse fliegen in Brusthöhe: so weit über ihrer Bodenposition werden sie gezeichnet
const SHOT_HEIGHT := 14.0

## Wer getroffen wird und wo Einschläge erscheinen (setzt die Run-Szene)
var target: Player
var effect_manager: EffectManager
var bounds := Rect2()
var count := 0

var _positions := PackedVector2Array()
var _velocities := PackedVector2Array()
var _life := PackedFloat32Array()
var _damage := PackedFloat32Array()
var _kind := PackedInt32Array()
var _kinds: Array[RangedAbility] = []
var _time := 0.0


func _ready() -> void:
	_positions.resize(MAX_SHOTS)
	_velocities.resize(MAX_SHOTS)
	_life.resize(MAX_SHOTS)
	_damage.resize(MAX_SHOTS)
	_kind.resize(MAX_SHOTS)


## Neues Geschoss der Fähigkeit kind ab from (Bodenposition) in Richtung direction
func spawn(kind: RangedAbility, from: Vector2, direction: Vector2, damage: float) -> void:
	if count >= MAX_SHOTS:
		return
	var slot := _kinds.find(kind)
	if slot == -1:
		_kinds.append(kind)
		slot = _kinds.size() - 1
	_positions[count] = from
	_velocities[count] = direction.normalized() * kind.shot_speed
	_life[count] = kind.shot_lifetime
	_damage[count] = damage
	_kind[count] = slot
	count += 1


func remove_all() -> void:
	count = 0


func _process(delta: float) -> void:
	_time += delta
	var hero := target.global_position if target else Vector2.INF
	var body := target.body_radius if target else 0.0
	# Rückwärts, weil _remove() das letzte Geschoss auf den freien Platz setzt
	for i in range(count - 1, -1, -1):
		var kind := _kinds[_kind[i]]
		_positions[i] += _velocities[i] * delta
		_life[i] -= delta
		var reach := kind.shot_radius + body
		if target and _positions[i].distance_squared_to(hero) <= reach * reach:
			target.take_damage(_damage[i])
			_burst(i, kind)
		elif _life[i] <= 0.0 or (bounds.has_area() and not bounds.has_point(_positions[i])):
			_burst(i, kind)
	if count > 0 or _time > 0.0:
		queue_redraw()


func _burst(i: int, kind: RangedAbility) -> void:
	if effect_manager and kind.impact_effect:
		effect_manager.play(kind.impact_effect, _positions[i] - Vector2(0.0, SHOT_HEIGHT))
	count -= 1
	if i != count:
		_positions[i] = _positions[count]
		_velocities[i] = _velocities[count]
		_life[i] = _life[count]
		_damage[i] = _damage[count]
		_kind[i] = _kind[count]


func _draw() -> void:
	for i in count:
		var kind := _kinds[_kind[i]]
		var texture := kind.shot_texture
		if not texture:
			continue
		var frame_size := Vector2(kind.shot_frame_width, texture.get_height())
		var frames := maxi(1, int(texture.get_width() / float(kind.shot_frame_width)))
		var frame := int((_time + i * 0.13) * kind.shot_fps) % frames
		var top_left := (_positions[i] - Vector2(0.0, SHOT_HEIGHT) - frame_size * 0.5).round()
		draw_texture_rect_region(texture, Rect2(top_left, frame_size), Rect2(Vector2(frame * kind.shot_frame_width, 0), frame_size))
