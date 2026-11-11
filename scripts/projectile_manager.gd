class_name ProjectileManager
extends Node2D
## Verwaltet alle Geschosse zentral (wie der EnemyManager): Werte liegen in Arrays, keine Nodes, keine Physik.
## - Pooling: Arrays einmal für MAX_PROJECTILES angelegt, ein entferntes Geschoss wird durch das letzte ersetzt.
## - Geschosse tragen ihren fertigen Schaden und merken sich nur den Index ihrer Waffe.
## - Geschosse fliegen in der Fußebene (wie alle Kollisionen) und werden SHOT_HEIGHT Pixel höher gezeichnet.

const MAX_PROJECTILES := 1000
## Flughöhe über den Füßen in Welt-Pixeln (Körpermitte)
const SHOT_HEIGHT := 14.0

## Gegner, auf die geschossen wird (setzt die Run-Szene)
var enemy_manager: EnemyManager
## Bereich, den Geschosse nicht verlassen (setzt die Run-Szene)
var bounds := Rect2()
var count := 0

var _positions := PackedVector2Array()
var _velocities := PackedVector2Array()
var _damage := PackedFloat32Array()
var _life := PackedFloat32Array()
var _pierce := PackedInt32Array()
var _weapon_index := PackedInt32Array()
## Zuletzt getroffener Gegner, damit ein durchschlagendes Geschoss ihn nicht gleich nochmal trifft
var _last_hit := PackedInt32Array()
## Alle Waffen, die schon einmal geschossen haben (ein Geschoss speichert nur den Index hierher)
var _weapons: Array[WeaponInstance] = []
var _time := 0.0


func _ready() -> void:
	_positions.resize(MAX_PROJECTILES)
	_velocities.resize(MAX_PROJECTILES)
	_damage.resize(MAX_PROJECTILES)
	_life.resize(MAX_PROJECTILES)
	_pierce.resize(MAX_PROJECTILES)
	_weapon_index.resize(MAX_PROJECTILES)
	_last_hit.resize(MAX_PROJECTILES)


## Neues Geschoss in der Fußebene bei from, Werte aus der Waffe (zum Zeitpunkt des Schusses).
func spawn(weapon: WeaponInstance, from: Vector2, direction: Vector2) -> void:
	if count >= MAX_PROJECTILES:
		return
	var index := _weapons.find(weapon)
	if index == -1:
		_weapons.append(weapon)
		index = _weapons.size() - 1
	_positions[count] = from
	_velocities[count] = direction * weapon.get_stat(&"projectile_speed")
	_damage[count] = weapon.get_stat(&"damage")
	_life[count] = weapon.get_stat(&"projectile_lifetime")
	_pierce[count] = maxi(1, roundi(weapon.get_stat(&"pierce")))
	_weapon_index[count] = index
	_last_hit[count] = -1
	count += 1


## Entfernt Geschoss i: Das letzte rückt auf seinen Platz.
func remove(i: int) -> void:
	count -= 1
	if i == count:
		return
	_positions[i] = _positions[count]
	_velocities[i] = _velocities[count]
	_damage[i] = _damage[count]
	_life[i] = _life[count]
	_pierce[i] = _pierce[count]
	_weapon_index[i] = _weapon_index[count]
	_last_hit[i] = _last_hit[count]


func _process(delta: float) -> void:
	_time += delta
	# Rückwärts, weil remove() das letzte Geschoss auf den freien Platz setzt (das wurde schon geprüft)
	for i in range(count - 1, -1, -1):
		var pos := _positions[i] + _velocities[i] * delta
		_positions[i] = pos
		_life[i] -= delta
		if _life[i] <= 0.0 or not bounds.has_point(pos):
			remove(i)
			continue
		if not enemy_manager:
			continue
		var weapon := _weapons[_weapon_index[i]]
		var hit := enemy_manager.find_hit(pos, weapon.get_stat(&"projectile_radius"))
		if hit == -1 or hit == _last_hit[i]:
			continue
		var hit_position := enemy_manager.get_enemy_position(hit)
		enemy_manager.damage(hit, _damage[i])
		for effect in weapon.data.effects:
			effect.on_hit(weapon, hit_position, hit, self)
		for effect in weapon.extra_effects:
			effect.on_hit(weapon, hit_position, hit, self)
		_last_hit[i] = hit
		_pierce[i] -= 1
		if _pierce[i] <= 0:
			remove(i)
	queue_redraw()


func _draw() -> void:
	for i in count:
		var data := _weapons[_weapon_index[i]].data
		var texture := data.projectile_texture
		if not texture:
			continue
		var frame_size := Vector2(data.frame_width, texture.get_height())
		var frames := maxi(1, int(texture.get_width() / float(data.frame_width)))
		var frame := int(_time * data.animation_fps) % frames
		var source := Rect2(Vector2(frame * data.frame_width, 0), frame_size)
		# Das Bild schaut nach Osten und wird in Flugrichtung gedreht
		draw_set_transform(_positions[i] - Vector2(0.0, SHOT_HEIGHT), _velocities[i].angle())
		draw_texture_rect_region(texture, Rect2(-frame_size * 0.5, frame_size), source)
	draw_set_transform(Vector2.ZERO)
