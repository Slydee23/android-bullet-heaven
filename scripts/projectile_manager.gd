class_name ProjectileManager
extends Node2D
## Verwaltet alle Geschosse zentral (wie der EnemyManager): Werte liegen in Arrays, keine Nodes, keine Physik.
## - Pooling: Arrays einmal für MAX_PROJECTILES angelegt, ein entferntes Geschoss wird durch das letzte ersetzt.
## - Geschosse tragen ihren fertigen Schaden und merken sich nur den Index ihrer Waffe.
## - Geschosse fliegen in der Fußebene (wie alle Kollisionen) und werden SHOT_HEIGHT Pixel höher gezeichnet.
## - Salven: Überzählige Geschosse einer Waffe warten in einer kleinen Warteschlange und starten zeitversetzt.

const MAX_PROJECTILES := 1000
## So viele Salven-Geschosse können gleichzeitig warten
const MAX_QUEUED := 256
## Flughöhe über den Füßen in Welt-Pixeln (Körpermitte)
const SHOT_HEIGHT := 14.0

## Gegner, auf die geschossen wird (setzt die Run-Szene)
var enemy_manager: EnemyManager
## Wer schießt (der Held): Salven starten von seiner aktuellen Position (setzt die Run-Szene)
var shooter: Node2D
## Bereich, den Geschosse nicht verlassen (setzt die Run-Szene)
var bounds := Rect2()
var count := 0
var queued_count := 0

var _positions := PackedVector2Array()
var _velocities := PackedVector2Array()
var _damage := PackedFloat32Array()
var _life := PackedFloat32Array()
var _pierce := PackedInt32Array()
var _weapon_index := PackedInt32Array()
## ID des zuletzt getroffenen Gegners (nicht der Platz: Plätze ändern sich beim Tod anderer Gegner)
var _last_hit_id := PackedInt32Array()
## Wartende Salven-Geschosse: Waffe, ID des Ziels und Restzeit bis zum Start
var _queue_weapon := PackedInt32Array()
var _queue_target_id := PackedInt32Array()
var _queue_delay := PackedFloat32Array()
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
	_last_hit_id.resize(MAX_PROJECTILES)
	_queue_weapon.resize(MAX_QUEUED)
	_queue_target_id.resize(MAX_QUEUED)
	_queue_delay.resize(MAX_QUEUED)


## Neues Geschoss in der Fußebene bei from, Werte aus der Waffe (zum Zeitpunkt des Schusses).
func spawn(weapon: WeaponInstance, from: Vector2, direction: Vector2) -> void:
	if count >= MAX_PROJECTILES:
		return
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	_positions[count] = from
	_velocities[count] = direction * weapon.get_stat(&"projectile_speed")
	_damage[count] = weapon.get_stat(&"damage")
	_life[count] = weapon.get_stat(&"projectile_lifetime")
	_pierce[count] = maxi(1, roundi(weapon.get_stat(&"pierce")))
	_weapon_index[count] = _weapon_slot(weapon)
	_last_hit_id[count] = -1
	count += 1


## Ein Geschoss der Waffe startet nach delay Sekunden vom Helden aus auf den Gegner mit dieser ID
## (ist er dann tot: auf den nächsten Gegner in Reichweite, gibt es keinen, verfällt das Geschoss).
func schedule(weapon: WeaponInstance, target_id: int, delay: float) -> void:
	if queued_count >= MAX_QUEUED:
		return
	_queue_weapon[queued_count] = _weapon_slot(weapon)
	_queue_target_id[queued_count] = target_id
	_queue_delay[queued_count] = delay
	queued_count += 1


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
	_last_hit_id[i] = _last_hit_id[count]


func _weapon_slot(weapon: WeaponInstance) -> int:
	var index := _weapons.find(weapon)
	if index == -1:
		_weapons.append(weapon)
		index = _weapons.size() - 1
	return index


func _process(delta: float) -> void:
	_time += delta
	_update_queue(delta)
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
		if hit == -1:
			continue
		var hit_id := enemy_manager.get_id(hit)
		if hit_id == _last_hit_id[i]:
			continue
		var hit_position := enemy_manager.get_enemy_position(hit)
		enemy_manager.damage(hit, _damage[i], weapon.data.element)
		for effect in weapon.data.effects:
			effect.on_hit(weapon, hit_position, hit, self)
		for effect in weapon.extra_effects:
			effect.on_hit(weapon, hit_position, hit, self)
		_last_hit_id[i] = hit_id
		_pierce[i] -= 1
		if _pierce[i] <= 0:
			remove(i)
	queue_redraw()


## Wartende Salven-Geschosse herunterzählen und fällige starten (rückwärts, weil beim Entfernen das letzte nachrückt).
func _update_queue(delta: float) -> void:
	for i in range(queued_count - 1, -1, -1):
		_queue_delay[i] -= delta
		if _queue_delay[i] > 0.0:
			continue
		var weapon := _weapons[_queue_weapon[i]]
		var target_id := _queue_target_id[i]
		queued_count -= 1
		_queue_weapon[i] = _queue_weapon[queued_count]
		_queue_target_id[i] = _queue_target_id[queued_count]
		_queue_delay[i] = _queue_delay[queued_count]
		_fire_queued(weapon, target_id)


func _fire_queued(weapon: WeaponInstance, target_id: int) -> void:
	if not shooter or not enemy_manager:
		return
	var origin := shooter.global_position
	var target := enemy_manager.find_index_by_id(target_id)
	if target == -1:
		target = enemy_manager.find_nearest(origin, weapon.get_stat(&"range"))
	if target == -1:
		return
	spawn(weapon, origin, origin.direction_to(enemy_manager.get_enemy_position(target)))


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
