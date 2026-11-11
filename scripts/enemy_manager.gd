class_name EnemyManager
extends Node2D
## Verwaltet alle Gegner zentral. Statt einem Node mit Physik pro Gegner liegen alle Werte in Arrays
## und werden in einer Schleife bewegt und in einem Durchgang gezeichnet – so bleiben Hunderte Gegner flüssig.
## - Pooling: Die Arrays werden einmal für MAX_ENEMIES angelegt. Ein toter Gegner wird durch den letzten ersetzt,
##   es wird nie neu Speicher angelegt oder freigegeben.
## - Spatial Grid: Jeder Gegner prüft nur Gegner in den Nachbarzellen statt alle anderen.

const MAX_ENEMIES := 2000
## Kantenlänge einer Rasterzelle in Welt-Pixeln (größer als der größte Gegnerdurchmesser)
const CELL_SIZE := 32.0
## Wie stark sich überlappende Gegner pro Frame auseinanderschieben (0..1)
const SEPARATION_STRENGTH := 0.5
## Sekunden zwischen zwei Spawns (M3: fester Wert, ab M7 aus den Wellen)
const SPAWN_INTERVAL := 0.5
## Maximal gleichzeitig lebende Gegner (M3: fester Wert, ab M7 aus den Wellen)
const MAX_ALIVE := 120
## So weit außerhalb des sichtbaren Bereichs erscheinen neue Gegner (Welt-Pixel)
const SPAWN_MARGIN := 32.0
const SPAWN_ATTEMPTS := 8
## Spielraum, ab dem ein stehender Gegner den Helden noch erreicht (Welt-Pixel)
const ATTACK_TOLERANCE := 1.0
## So lange leuchtet ein getroffener Gegner hell auf (Sekunden)
const HIT_FLASH_TIME := 0.1
## Farbe des Aufleuchtens (über 1 = heller als das Bild, wird auf Weiß begrenzt)
const HIT_FLASH_COLOR := Color(3.0, 3.0, 3.0)

## Ein Gegner ist gestorben (position = Füße). Anschluss für Effekte (M4b) und XP-Kristalle (M6).
signal enemy_killed(position: Vector2, data: EnemyData)

## Ziel, auf das alle Gegner zulaufen und das sie angreifen (der Held)
var target: Player
## Gegnertypen, aus denen zufällig gespawnt wird
var spawn_types: Array[EnemyData] = []
## Anzahl lebender Gegner (belegt sind die Plätze 0 bis count-1)
var count := 0

var _bounds := Rect2()
var _type_list: Array[EnemyData] = []
var _types := PackedInt32Array()
var _positions := PackedVector2Array()
var _hp := PackedFloat32Array()
var _anim_offsets := PackedFloat32Array()
var _flipped := PackedByteArray()
var _attack_timers := PackedFloat32Array()
## Restzeit des Treffer-Aufleuchtens
var _flash := PackedFloat32Array()
var _grid_size := Vector2i.ONE
var _cell_head := PackedInt32Array()
var _cell_next := PackedInt32Array()
## Sortierung nach Höhe: pro Pixelzeile der Arena eine Liste der Gegner, die dort stehen
var _row_head := PackedInt32Array()
var _row_next := PackedInt32Array()
var _spawn_timer := 0.0
var _time := 0.0


func _ready() -> void:
	_types.resize(MAX_ENEMIES)
	_positions.resize(MAX_ENEMIES)
	_hp.resize(MAX_ENEMIES)
	_anim_offsets.resize(MAX_ENEMIES)
	_flipped.resize(MAX_ENEMIES)
	_attack_timers.resize(MAX_ENEMIES)
	_flash.resize(MAX_ENEMIES)
	_cell_next.resize(MAX_ENEMIES)
	_row_next.resize(MAX_ENEMIES)


## Bereich, den Gegner nicht verlassen (setzt die Run-Szene). Baut das Raster passend zur Arena.
func set_bounds(bounds: Rect2) -> void:
	_bounds = bounds
	_grid_size = Vector2i((bounds.size / CELL_SIZE).ceil()) + Vector2i.ONE
	_cell_head.resize(_grid_size.x * _grid_size.y)
	_row_head.resize(int(ceilf(bounds.size.y)) + 1)


func spawn(data: EnemyData, pos: Vector2) -> void:
	if count >= MAX_ENEMIES:
		return
	var type_index := _type_list.find(data)
	if type_index == -1:
		_type_list.append(data)
		type_index = _type_list.size() - 1
	_types[count] = type_index
	_positions[count] = pos
	_hp[count] = data.max_hp
	_anim_offsets[count] = randf() * 10.0  # damit nicht alle im Gleichschritt laufen
	_flipped[count] = 0
	_attack_timers[count] = 0.0
	_flash[count] = 0.0
	count += 1


## Entfernt Gegner i: Der letzte Gegner rückt auf seinen Platz.
func kill(i: int) -> void:
	count -= 1
	if i == count:
		return
	_types[i] = _types[count]
	_positions[i] = _positions[count]
	_hp[i] = _hp[count]
	_anim_offsets[i] = _anim_offsets[count]
	_flipped[i] = _flipped[count]
	_attack_timers[i] = _attack_timers[count]
	_flash[i] = _flash[count]


## Zieht Gegner i Lebenspunkte ab. Stirbt er, wird er erst zu Beginn des nächsten Frames entfernt
## (sofortiges Entfernen würde die Plätze der anderen Gegner mitten in einer Schleife verschieben).
func damage(i: int, amount: float) -> void:
	_hp[i] -= amount
	_flash[i] = HIT_FLASH_TIME


func get_enemy_position(i: int) -> Vector2:
	return _positions[i]


## Nächster lebender Gegner im Umkreis max_range um pos (Füße), oder -1.
## Läuft einmal über alle Gegner mit quadrierten Distanzen: Das reicht, weil es nur einmal pro Waffen-Schuss geschieht.
func find_nearest(pos: Vector2, max_range: float) -> int:
	var best := -1
	var best_sq := max_range * max_range
	for i in count:
		if _hp[i] <= 0.0:
			continue
		var distance_sq := pos.distance_squared_to(_positions[i])
		if distance_sq <= best_sq:
			best_sq = distance_sq
			best = i
	return best


## Erster lebender Gegner, dessen Körperkreis den Kreis (pos, radius) berührt, oder -1. Nutzt das Spatial Grid.
func find_hit(pos: Vector2, radius: float) -> int:
	var cell := _cell_of(pos)
	for cy in range(maxi(cell.y - 1, 0), mini(cell.y + 2, _grid_size.y)):
		for cx in range(maxi(cell.x - 1, 0), mini(cell.x + 2, _grid_size.x)):
			var j := _cell_head[cy * _grid_size.x + cx]
			while j != -1:
				if _hp[j] > 0.0:
					var reach := radius + _type_list[_types[j]].radius
					if pos.distance_squared_to(_positions[j]) <= reach * reach:
						return j
				j = _cell_next[j]
	return -1


## Entfernt alle gestorbenen Gegner. Rückwärts, weil kill() den letzten Gegner auf den freien Platz setzt.
func _remove_dead() -> void:
	for i in range(count - 1, -1, -1):
		if _hp[i] <= 0.0:
			enemy_killed.emit(_positions[i], _type_list[_types[i]])
			kill(i)


func _process(delta: float) -> void:
	_time += delta
	_remove_dead()
	_update_spawning(delta)
	_build_grid()
	_move(delta)
	queue_redraw()


func _update_spawning(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer > 0.0 or count >= MAX_ALIVE or spawn_types.is_empty():
		return
	_spawn_timer = SPAWN_INTERVAL
	spawn(spawn_types.pick_random(), _find_spawn_position())


## Zufälliger Punkt knapp außerhalb des sichtbaren Bereichs, aber innerhalb der Arena.
func _find_spawn_position() -> Vector2:
	var view := get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()
	var distance := view.size.length() * 0.5 + SPAWN_MARGIN
	var point := view.get_center()
	for _attempt in SPAWN_ATTEMPTS:
		point = view.get_center() + Vector2.from_angle(randf() * TAU) * distance
		if _bounds.has_point(point):
			return point
	# Kein Platz außerhalb des Sichtfelds (z. B. Held in der Arena-Ecke): am Arenarand erscheinen
	return point.clamp(_bounds.position, _bounds.end)


func _cell_of(pos: Vector2) -> Vector2i:
	var cell := Vector2i((pos - _bounds.position) / CELL_SIZE)
	return cell.clamp(Vector2i.ZERO, _grid_size - Vector2i.ONE)


func _build_grid() -> void:
	_cell_head.fill(-1)
	for i in count:
		var cell := _cell_of(_positions[i])
		var c := cell.y * _grid_size.x + cell.x
		_cell_next[i] = _cell_head[c]
		_cell_head[c] = i


func _move(delta: float) -> void:
	var target_pos := target.global_position if target else _bounds.get_center()
	var target_radius := target.body_radius if target else 0.0
	for i in count:
		var data := _type_list[_types[i]]
		_flash[i] = maxf(_flash[i] - delta, 0.0)
		var pos := _positions[i]
		var direction := pos.direction_to(target_pos)
		# Am Rand des Helden bzw. in Angriffsreichweite stehen bleiben
		var contact_distance := data.radius + target_radius
		var stop_distance := contact_distance + data.attack_range
		var target_distance := pos.distance_to(target_pos)
		if target_distance > stop_distance:
			pos += direction * minf(data.speed * delta, target_distance - stop_distance)
		_flipped[i] = 1 if direction.x < 0.0 else 0

		# Abstand zu Nachbarn halten, damit sie sich nicht auf einem Punkt stapeln
		var push := Vector2.ZERO
		var cell := _cell_of(pos)
		for cy in range(maxi(cell.y - 1, 0), mini(cell.y + 2, _grid_size.y)):
			for cx in range(maxi(cell.x - 1, 0), mini(cell.x + 2, _grid_size.x)):
				var j := _cell_head[cy * _grid_size.x + cx]
				while j != -1:
					if j != i:
						var offset := pos - _positions[j]
						var min_distance := data.radius + _type_list[_types[j]].radius
						var distance_sq := offset.length_squared()
						if distance_sq < min_distance * min_distance and distance_sq > 0.0001:
							var distance := sqrt(distance_sq)
							push += offset / distance * (min_distance - distance)
					j = _cell_next[j]
		pos += push * SEPARATION_STRENGTH

		# Nie im Helden stehen: Läuft er in Gegner hinein, weichen sie zur Seite. Ihn selbst bremst das nicht.
		var away := pos - target_pos
		if away.length_squared() < contact_distance * contact_distance:
			pos = target_pos + (away.normalized() if away != Vector2.ZERO else Vector2.RIGHT) * contact_distance
		pos = pos.clamp(_bounds.position, _bounds.end)
		_positions[i] = pos

		_update_attack(i, data, pos.distance_to(target_pos) <= stop_distance + ATTACK_TOLERANCE, delta)


func _update_attack(i: int, data: EnemyData, in_range: bool, delta: float) -> void:
	if _attack_timers[i] > 0.0:
		_attack_timers[i] -= delta
	elif in_range and target and target.take_damage(data.contact_damage):
		# Trifft der Angriff nicht (I-Frames des Helden), bleibt der Gegner bereit und versucht es weiter
		_attack_timers[i] = data.attack_interval


## Zeichnet von oben nach unten: Wer weiter unten steht (näher an der Kamera), verdeckt die dahinter.
## Sortiert wird pro Pixelzeile (Bucket-Sort mit verketteten Listen), ohne neue Arrays.
func _draw() -> void:
	_row_head.fill(-1)
	var last_row := _row_head.size() - 1
	for i in count:
		var row := clampi(int(_positions[i].y - _bounds.position.y), 0, last_row)
		_row_next[i] = _row_head[row]
		_row_head[row] = i
	for row in _row_head.size():
		var i := _row_head[row]
		while i != -1:
			_draw_enemy(i)
			i = _row_next[i]
	draw_set_transform(Vector2.ZERO)


func _draw_enemy(i: int) -> void:
	var data := _type_list[_types[i]]
	var texture := data.walk_texture
	var frame_size := Vector2(data.frame_width, texture.get_height())
	var frames := maxi(1, int(texture.get_width() / float(data.frame_width)))
	var frame := int((_time + _anim_offsets[i]) * data.animation_fps) % frames
	var source := Rect2(Vector2(frame * data.frame_width, 0), frame_size)
	var flip_scale := Vector2(-1.0 if _flipped[i] else 1.0, 1.0) * data.draw_scale
	draw_set_transform(_positions[i], 0.0, flip_scale)
	# Die Position sind die Füße: Das Bild steht unten bündig darauf
	var frame_rect := Rect2(Vector2(-frame_size.x * 0.5, 1.0 - frame_size.y), frame_size)
	draw_texture_rect_region(texture, frame_rect, source, HIT_FLASH_COLOR if _flash[i] > 0.0 else Color.WHITE)
