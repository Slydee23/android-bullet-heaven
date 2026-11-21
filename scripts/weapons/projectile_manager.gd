class_name ProjectileManager
extends Node2D
## Verwaltet alle Geschosse zentral (wie der EnemyManager): Werte liegen in Arrays, keine Nodes, keine Physik.
## - Pooling: Arrays einmal für MAX_PROJECTILES angelegt, ein entferntes Geschoss wird durch das letzte ersetzt.
## - Geschosse tragen ihren fertigen Schaden und merken sich nur den Index ihrer Waffe.
## - Geschosse fliegen in der Fußebene (wie alle Kollisionen) und werden SHOT_HEIGHT Pixel höher gezeichnet.
## - Salven: Überzählige Geschosse einer Waffe warten in einer kleinen Warteschlange und starten zeitversetzt.
## - Bewegungsart ORBIT (kreisende Klingen): Das Geschoss kreist um den Helden, lebt bis es entfernt wird, trifft alle
##   Gegner in seinem Radius und merkt sich pro Gegner, wann es ihn zuletzt getroffen hat (Treffer-Takt `hit_interval`).

enum Mode { FLY, ORBIT }

const MAX_PROJECTILES := 1000
## So viele Salven-Geschosse können gleichzeitig warten
const MAX_QUEUED := 256
## So viele zuletzt getroffene Gegner merkt sich eine kreisende Klinge (danach wird der älteste Eintrag ersetzt)
const HIT_MEMORY := 16
## So viele Gegner kann eine kreisende Klinge in einem Frame treffen
const MAX_ORBIT_HITS := 64
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
## Restliche Abpraller (Stat ricochet): Statt zu verschwinden, fliegt das Geschoss zum nächsten Gegner weiter
var _bounces := PackedInt32Array()
## ID des Gegners vor dem zuletzt getroffenen: Abpraller springen nie direkt dorthin zurück
var _prev_hit_id := PackedInt32Array()
## Arbeitsspeicher für die Abpraller-Ziele
var _bounce_targets := PackedInt32Array()
var _weapon_index := PackedInt32Array()
## ID des zuletzt getroffenen Gegners (nicht der Platz: Plätze ändern sich beim Tod anderer Gegner)
var _last_hit_id := PackedInt32Array()
var _mode := PackedInt32Array()
## Winkel der kreisenden Klingen (Bogenmaß)
var _orbit_angle := PackedFloat32Array()
## Treffer-Gedächtnis der kreisenden Klingen: HIT_MEMORY Einträge pro Geschoss (Gegner-ID und Zeitpunkt), Ringpuffer
var _memory_id := PackedInt32Array()
var _memory_time := PackedFloat32Array()
var _memory_next := PackedInt32Array()
## Wiederverwendeter Puffer für die Gegner unter einer Klinge
var _orbit_hits := PackedInt32Array()
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
	_bounces.resize(MAX_PROJECTILES)
	_prev_hit_id.resize(MAX_PROJECTILES)
	_weapon_index.resize(MAX_PROJECTILES)
	_last_hit_id.resize(MAX_PROJECTILES)
	_mode.resize(MAX_PROJECTILES)
	_orbit_angle.resize(MAX_PROJECTILES)
	_memory_id.resize(MAX_PROJECTILES * HIT_MEMORY)
	_memory_time.resize(MAX_PROJECTILES * HIT_MEMORY)
	_memory_next.resize(MAX_PROJECTILES)
	_orbit_hits.resize(MAX_ORBIT_HITS)
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
	_bounces[count] = maxi(0, roundi(weapon.get_stat(&"ricochet")))
	_prev_hit_id[count] = -1
	_weapon_index[count] = _weapon_slot(weapon)
	_last_hit_id[count] = -1
	_mode[count] = Mode.FLY
	count += 1


## Neue kreisende Klinge der Waffe beim Winkel angle (Bogenmaß). Sie bleibt, bis remove_weapon() sie entfernt.
func spawn_orbit(weapon: WeaponInstance, angle: float) -> void:
	if count >= MAX_PROJECTILES:
		return
	var dir := Vector2.from_angle(angle)
	var center := shooter.global_position if shooter else Vector2.ZERO
	_positions[count] = center + dir * weapon.get_stat(&"range")
	_velocities[count] = dir
	_damage[count] = weapon.get_stat(&"damage")
	_life[count] = INF
	_pierce[count] = 0
	_bounces[count] = 0
	_weapon_index[count] = _weapon_slot(weapon)
	_last_hit_id[count] = -1
	_mode[count] = Mode.ORBIT
	_orbit_angle[count] = angle
	_memory_next[count] = 0
	var base := count * HIT_MEMORY
	for k in HIT_MEMORY:
		_memory_id[base + k] = -1
	count += 1


## Entfernt alle Geschosse dieser Waffe (z. B. die Klingen am Ende ihrer Wirkdauer).
func remove_weapon(weapon: WeaponInstance) -> void:
	var index := _weapons.find(weapon)
	if index == -1:
		return
	for i in range(count - 1, -1, -1):
		if _weapon_index[i] == index:
			remove(i)


## Anzahl der Geschosse dieser Waffe (läuft über alle Geschosse: nur bei seltenen Ereignissen aufrufen, nicht pro Frame).
func count_of(weapon: WeaponInstance) -> int:
	var index := _weapons.find(weapon)
	var result := 0
	for i in count:
		if _weapon_index[i] == index:
			result += 1
	return result


## Winkel der ersten kreisenden Klinge dieser Waffe (0, wenn sie keine hat). Beim Neuverteilen der Klingen bleibt so die Drehung erhalten.
func orbit_phase(weapon: WeaponInstance) -> float:
	var index := _weapons.find(weapon)
	for i in count:
		if _weapon_index[i] == index and _mode[i] == Mode.ORBIT:
			return _orbit_angle[i]
	return 0.0


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
	_bounces[i] = _bounces[count]
	_prev_hit_id[i] = _prev_hit_id[count]
	_weapon_index[i] = _weapon_index[count]
	_last_hit_id[i] = _last_hit_id[count]
	_mode[i] = _mode[count]
	_orbit_angle[i] = _orbit_angle[count]
	_memory_next[i] = _memory_next[count]
	var to := i * HIT_MEMORY
	var from := count * HIT_MEMORY
	for k in HIT_MEMORY:
		_memory_id[to + k] = _memory_id[from + k]
		_memory_time[to + k] = _memory_time[from + k]


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
		if _mode[i] == Mode.ORBIT:
			_update_orbit(i, delta)
			continue
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
		_hit(weapon, hit, _damage[i])
		_prev_hit_id[i] = _last_hit_id[i]
		_last_hit_id[i] = hit_id
		_pierce[i] -= 1
		if _pierce[i] <= 0:
			if _bounces[i] > 0 and _bounce(i, weapon, hit):
				_bounces[i] -= 1
				_pierce[i] = 1
			else:
				remove(i)
	queue_redraw()


## Abpraller: Geschoss i fliegt vom getroffenen Gegner zum nächsten Gegner in Reichweite weiter, aber nie zurück zum
## gerade oder davor getroffenen. false = kein weiteres Ziel, das Geschoss verschwindet.
func _bounce(i: int, weapon: WeaponInstance, hit: int) -> bool:
	var found := enemy_manager.find_nearest_n(_positions[i], weapon.get_stat(&"range"), 3, _bounce_targets)
	for k in found:
		var target := _bounce_targets[k]
		if target != hit and enemy_manager.get_id(target) != _prev_hit_id[i]:
			_velocities[i] = _positions[i].direction_to(enemy_manager.get_enemy_position(target)) * weapon.get_stat(&"projectile_speed")
			_life[i] = weapon.get_stat(&"projectile_lifetime")
			return true
	return false


## Schaden an Gegner hit, Schadenszähler der Waffe und Treffer-Effekte
func _hit(weapon: WeaponInstance, hit: int, amount: float) -> void:
	var hit_position := enemy_manager.get_enemy_position(hit)
	weapon.total_damage += enemy_manager.damage(hit, amount, weapon.data.element)
	for effect in weapon.data.effects:
		effect.on_hit(weapon, hit_position, hit, self)
	for effect in weapon.extra_effects:
		effect.on_hit(weapon, hit_position, hit, self)


## Kreisende Klinge: weiterdrehen, dem Helden folgen, alle Gegner unter ihr treffen, die sie länger als hit_interval nicht getroffen hat.
## Werte werden jeden Frame frisch gelesen, damit Upgrades sofort wirken.
func _update_orbit(i: int, delta: float) -> void:
	var weapon := _weapons[_weapon_index[i]]
	var angle := _orbit_angle[i] + weapon.get_stat(&"orbit_speed") * delta
	_orbit_angle[i] = angle
	var dir := Vector2.from_angle(angle)
	if shooter:
		_positions[i] = shooter.global_position + dir * weapon.get_stat(&"range")
	# Zeigt nach außen: Die Zeichen-Drehung richtet die Spitze der Klinge damit vom Helden weg
	_velocities[i] = dir
	if not enemy_manager:
		return
	var found := enemy_manager.find_all_in_radius(_positions[i], weapon.get_stat(&"projectile_radius"), _orbit_hits)
	if found == 0:
		return
	var interval := weapon.get_stat(&"hit_interval")
	var amount := weapon.get_stat(&"damage")
	for k in found:
		var hit := _orbit_hits[k]
		var hit_id := enemy_manager.get_id(hit)
		if _recently_hit(i, hit_id, interval):
			continue
		_remember_hit(i, hit_id)
		_hit(weapon, hit, amount)


func _recently_hit(i: int, enemy_id: int, interval: float) -> bool:
	var base := i * HIT_MEMORY
	for k in HIT_MEMORY:
		if _memory_id[base + k] == enemy_id and _time - _memory_time[base + k] < interval:
			return true
	return false


func _remember_hit(i: int, enemy_id: int) -> void:
	var slot := _memory_next[i]
	_memory_id[i * HIT_MEMORY + slot] = enemy_id
	_memory_time[i * HIT_MEMORY + slot] = _time
	_memory_next[i] = (slot + 1) % HIT_MEMORY


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
		# Das Bild schaut nach Osten und wird in Flugrichtung gedreht. Kreisende Klingen hängen an der Körpermitte des Helden,
		# fliegende Geschosse in der Höhe der Gegner-Körper.
		var height := Player.BODY_CENTER_HEIGHT if _mode[i] == Mode.ORBIT else SHOT_HEIGHT
		draw_set_transform(_positions[i] - Vector2(0.0, height), _velocities[i].angle())
		draw_texture_rect_region(texture, Rect2(-frame_size * 0.5, frame_size), source)
	draw_set_transform(Vector2.ZERO)
