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
## Jeder Treffer streut zufällig um diesen Anteil um den Waffenschaden (0.1 = 90–110 %) und wird auf ganze Zahlen gerundet,
## damit Schadenszahlen lebendig wirken. Die Durchschnittswerte (und damit die Balance) bleiben gleich.
const DAMAGE_SPREAD := 0.1
## So viele verschiedene Status-Effekte kann ein Gegner gleichzeitig tragen (Bitmaske, je ein Platz pro Status-Datei)
const MAX_STATUS := 4
## Unsterbliche Gegner (Übungspuppe) heilen sich so viele Sekunden nach dem letzten Treffer voll
const IMMORTAL_HEAL_DELAY := 2.0
## Kettenblitze: so viele gleichzeitig sichtbar, so lange (Sekunden) sichtbar, höchstens so viele Ziele pro Sprung
const MAX_ARCS := 64
const ARC_TIME := 0.18
const ARC_COLOR := Color("#ffe14a")
const MAX_CHAIN_TARGETS := 8
## Status-Partikel: so viele Pixel pro Status und Gegner
const STATUS_PARTICLES := 3
## Mehrere Status: so viele Sekunden zeigt die Tönung jeweils eine Farbe
const STATUS_CYCLE := 0.5

## Höchstanzahl der Ziele, die find_nearest_n auf einmal liefert
const MAX_NEAREST := 16

## Höhe der Körpermitte über den Füßen (Welt-Pixel): Dort sitzen Treffer-Effekte und Schadenszahlen
const BODY_HEIGHT := 14.0

## Lebensleiste über dem Kopf eines verletzten Gegners (dieselben Bilder wie die des Helden, 1× groß)
const BAR_FRAME := preload("res://assets/ui/bar_frame.png")
const BAR_FILL := preload("res://assets/ui/bar_fill.png")
const BAR_FILL_WIDTH := 14
const BAR_GAP := 3.0

## Ein Gegner hat Schaden genommen (position = Füße). Anschluss für Treffer-Effekte (M4b) und Schadenszahlen (M4c).
## element = Schadensart, crit = kritischer Treffer, kill = dieser Treffer hat den Gegner getötet.
## dot = Schaden über Zeit (Brennen, Gift): kleine Zahl, kein Aufleuchten, keine Treffer-Funken.
signal enemy_damaged(position: Vector2, amount: float, element: StringName, crit: bool, kill: bool, dot: bool)
## Ein Gegner ist gestorben (position = Füße). Anschluss für Effekte (M4b) und XP-Kristalle (M6).
signal enemy_killed(position: Vector2, data: EnemyData)

## Ziel, auf das alle Gegner zulaufen und das sie angreifen (der Held)
var target: Player
## Gegnertypen, aus denen zufällig gespawnt wird
var spawn_types: Array[EnemyData] = []
## Anzahl lebender Gegner (belegt sind die Plätze 0 bis count-1)
var count := 0
## Faktor auf die Lebenspunkte aller (sterblichen) Gegner, im Debug-Menü einstellbar
var hp_multiplier := 1.0
## Status-Dateien, die schon einmal angewendet wurden: ihr Platz hier ist ihr Bit in der Status-Maske
var status_types: Array[StatusEffectData] = []

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
## Stabile ID jedes Gegners: Beim Tod rückt der letzte Gegner nach und ändert seinen Platz, seine ID bleibt.
## Wer sich einen Gegner über mehrere Frames merken muss (Geschosse, Salven, Status-Effekte), merkt sich die ID.
var _ids := PackedInt32Array()
var _next_id := 1
## Sekunden seit dem letzten Treffer (Heilung der Übungspuppe)
var _since_hit := PackedFloat32Array()
## Status pro Gegner: Bitmaske der aktiven Status, dazu je Gegner MAX_STATUS Plätze mit Restzeit, Takt, Stapeln
var _status_mask := PackedInt32Array()
var _st_left := PackedFloat32Array()
var _st_tick := PackedFloat32Array()
var _st_stacks := PackedInt32Array()
## Sichtbare Kettenblitze (Start, Ziel in Körperhöhe, Alter)
var _arc_from := PackedVector2Array()
var _arc_to := PackedVector2Array()
var _arc_age := PackedFloat32Array()
var _arc_count := 0
## Arbeitsspeicher des Kettenblitzes (nächste Gegner und ihre Abstände)
var _chain_targets := PackedInt32Array()
var _chain_distances := PackedFloat32Array()
## Arbeitsspeicher von find_nearest_n (Abstände der bisher nächsten Gegner)
var _nearest_distances := PackedFloat32Array()
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
	_ids.resize(MAX_ENEMIES)
	_since_hit.resize(MAX_ENEMIES)
	_status_mask.resize(MAX_ENEMIES)
	_st_left.resize(MAX_ENEMIES * MAX_STATUS)
	_st_tick.resize(MAX_ENEMIES * MAX_STATUS)
	_st_stacks.resize(MAX_ENEMIES * MAX_STATUS)
	_arc_from.resize(MAX_ARCS)
	_arc_to.resize(MAX_ARCS)
	_arc_age.resize(MAX_ARCS)
	_chain_targets.resize(MAX_CHAIN_TARGETS)
	_chain_distances.resize(MAX_CHAIN_TARGETS)
	_nearest_distances.resize(MAX_NEAREST)
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
	_hp[count] = data.max_hp * (1.0 if data.immortal else hp_multiplier)
	_since_hit[count] = 0.0
	_status_mask[count] = 0
	_anim_offsets[count] = randf() * 10.0  # damit nicht alle im Gleichschritt laufen
	_flipped[count] = 0
	_attack_timers[count] = 0.0
	_flash[count] = 0.0
	_ids[count] = _next_id
	_next_id += 1
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
	_ids[i] = _ids[count]
	_since_hit[i] = _since_hit[count]
	_status_mask[i] = _status_mask[count]
	for s in MAX_STATUS:
		_st_left[i * MAX_STATUS + s] = _st_left[count * MAX_STATUS + s]
		_st_tick[i * MAX_STATUS + s] = _st_tick[count * MAX_STATUS + s]
		_st_stacks[i * MAX_STATUS + s] = _st_stacks[count * MAX_STATUS + s]


## Stabile ID von Gegner i (bleibt gleich, auch wenn sich sein Platz ändert).
func get_id(i: int) -> int:
	return _ids[i]


## Aktueller Platz des Gegners mit dieser ID, oder -1, wenn er nicht mehr lebt.
## Läuft linear über alle Gegner, ist also für seltene Abfragen gedacht (z. B. Salven), nicht für jeden Frame und jedes Geschoss.
func find_index_by_id(id: int) -> int:
	for i in count:
		if _ids[i] == id:
			return i if _hp[i] > 0.0 else -1
	return -1


func is_alive(i: int) -> bool:
	return i >= 0 and i < count and _hp[i] > 0.0


## Zieht Gegner i Lebenspunkte ab: amount streut um ±DAMAGE_SPREAD und wird gerundet (mindestens 1).
## Liefert den tatsächlich verursachten Schaden (für die Schadenszähler der Waffen).
## Stirbt er, wird er erst zu Beginn des nächsten Frames entfernt
## (sofortiges Entfernen würde die Plätze der anderen Gegner mitten in einer Schleife verschieben).
## Ist der Gegner geschockt (Status-Art CHAIN), springt ein Teil des Schadens als Kettenblitz auf nahe Gegner über.
func damage(i: int, amount: float, element: StringName = Elements.PHYSICAL, crit := false) -> float:
	var dealt := _apply_damage(i, amount, element, crit, false)
	if _status_mask[i] != 0:
		_chain_from(i, dealt)
	return dealt


## Schaden ohne Kettenblitz (für Ticks und die Kettenblitze selbst, damit keine Endlosschleife entsteht).
## dot: Schaden über Zeit, ohne Aufleuchten.
func _apply_damage(i: int, amount: float, element: StringName, crit: bool, dot: bool) -> float:
	var dealt := maxf(1.0, roundf(amount * randf_range(1.0 - DAMAGE_SPREAD, 1.0 + DAMAGE_SPREAD)))
	var was_alive := _hp[i] > 0.0
	_hp[i] -= dealt
	if _type_list[_types[i]].immortal:
		_hp[i] = maxf(_hp[i], 1.0)
	_since_hit[i] = 0.0
	if not dot:
		_flash[i] = HIT_FLASH_TIME
	enemy_damaged.emit(_positions[i], dealt, element, crit, was_alive and _hp[i] <= 0.0, dot)
	return dealt


## Schadet allen lebenden Gegnern, deren Körperkreis den Kreis (center, radius) berührt (Bomben, Blitze, Auren).
## Nutzt das Spatial Grid. Jeder Gegner bekommt seinen eigenen gestreuten Wert. Liefert den insgesamt verursachten Schaden.
func damage_in_radius(center: Vector2, radius: float, amount: float, element: StringName = Elements.PHYSICAL) -> float:
	var dealt := 0.0
	var reach := radius + CELL_SIZE * 0.5
	var first := _cell_of(center - Vector2(reach, reach))
	var last := _cell_of(center + Vector2(reach, reach))
	for cy in range(first.y, last.y + 1):
		for cx in range(first.x, last.x + 1):
			var j := _cell_head[cy * _grid_size.x + cx]
			while j != -1:
				if _hp[j] > 0.0:
					var touch := radius + _type_list[_types[j]].radius
					if center.distance_squared_to(_positions[j]) <= touch * touch:
						dealt += damage(j, amount, element)
				j = _cell_next[j]
	return dealt


## Schadet allen lebenden Gegnern in einem Streifen, der von origin gerade in direction wegführt (Peitschenhieb):
## von start bis start + length Pixel vor origin, half_width Pixel zu jeder Seite. Ein Gegner zählt, wenn sein Körperkreis
## den Streifen berührt. Nutzt das Spatial Grid. Liefert den insgesamt verursachten Schaden.
func damage_in_strip(origin: Vector2, direction: Vector2, start: float, length: float, half_width: float, amount: float, element: StringName = Elements.PHYSICAL) -> float:
	var dir := direction.normalized()
	var a := origin + dir * start
	var b := origin + dir * (start + length)
	var margin := half_width + CELL_SIZE * 0.5
	var first := _cell_of(Vector2(minf(a.x, b.x), minf(a.y, b.y)) - Vector2(margin, margin))
	var last := _cell_of(Vector2(maxf(a.x, b.x), maxf(a.y, b.y)) + Vector2(margin, margin))
	var dealt := 0.0
	for cy in range(first.y, last.y + 1):
		for cx in range(first.x, last.x + 1):
			var j := _cell_head[cy * _grid_size.x + cx]
			while j != -1:
				if _hp[j] > 0.0:
					var body := _type_list[_types[j]].radius
					var rel := _positions[j] - origin
					var along := rel.dot(dir)
					var side := absf(rel.cross(dir))
					if along >= start - body and along <= start + length + body and side <= half_width + body:
						dealt += damage(j, amount, element)
				j = _cell_next[j]
	return dealt


## Schadet allen lebenden Gegnern in einer Sichel (Peitsche): Die Form ist ein Kreis A ohne einen um `thickness`
## nach hinten verschobenen Kreis B gleicher Größe. Sie wölbt sich in Richtung `direction`, ihre Spitze liegt `reach` Pixel
## vor `origin`, vorne ist sie `thickness` dick und läuft zu den Seiten spitz aus. Ein größerer `radius` macht sie flacher und breiter.
## Ein Gegner zählt, wenn sein Körperkreis die Sichel berührt. Liefert den insgesamt verursachten Schaden.
func damage_in_crescent(origin: Vector2, direction: Vector2, reach: float, radius: float, thickness: float, amount: float, element: StringName = Elements.PHYSICAL) -> float:
	var dir := direction.normalized()
	var center_a := origin + dir * (reach - radius)
	var center_b := center_a - dir * thickness
	var dealt := 0.0
	var margin := radius + CELL_SIZE * 0.5
	var first := _cell_of(center_a - Vector2(margin, margin))
	var last := _cell_of(center_a + Vector2(margin, margin))
	for cy in range(first.y, last.y + 1):
		for cx in range(first.x, last.x + 1):
			var j := _cell_head[cy * _grid_size.x + cx]
			while j != -1:
				if _hp[j] > 0.0:
					var body := _type_list[_types[j]].radius
					var in_a := center_a.distance_squared_to(_positions[j]) <= (radius + body) * (radius + body)
					# Nicht ganz im Kreis B: der Gegner muss über dessen Rand hinausragen
					var not_in_b := center_b.distance_to(_positions[j]) > radius - body
					if in_a and not_in_b:
						dealt += damage(j, amount, element)
				j = _cell_next[j]
	return dealt


func get_enemy_position(i: int) -> Vector2:
	return _positions[i]


## Volle Lebenspunkte von Gegner i (Grundwert der Datei mal hp_multiplier, unsterbliche Gegner ohne Faktor)
func get_max_hp(i: int) -> float:
	var data := _type_list[_types[i]]
	return data.max_hp * (1.0 if data.immortal else hp_multiplier)


## Lebenspunkte-Faktor ändern (Debug): Vorhandene Gegner behalten ihren Anteil an Lebenspunkten.
func set_hp_multiplier(value: float) -> void:
	var ratio := value / hp_multiplier
	for i in count:
		if not _type_list[_types[i]].immortal:
			_hp[i] *= ratio
	hp_multiplier = value


## Entfernt alle Gegner sofort, ohne Tod-Effekte (Debug)
func remove_all() -> void:
	count = 0
	_arc_count = 0


## n Gegner gleichmäßig im Ring um center (Abstand zufällig zwischen r_min und r_max), innerhalb der Arena (Debug)
func spawn_ring(data: EnemyData, center: Vector2, n: int, r_min: float, r_max: float) -> void:
	for k in n:
		var pos := center + Vector2.from_angle(TAU * k / n + randf() * 0.2) * randf_range(r_min, r_max)
		spawn(data, pos.clamp(_bounds.position, _bounds.end))


## Status auf Gegner i: Ist er schon aktiv, wird die Dauer aufgefrischt und (bis max_stacks) ein Stapel aufgelegt.
## Bis zu MAX_STATUS verschiedene Status-Dateien bekommen beim ersten Einsatz je einen festen Platz in der Maske.
func apply_status(i: int, status: StatusEffectData) -> void:
	if i < 0 or i >= count or _hp[i] <= 0.0:
		return
	var slot := status_types.find(status)
	if slot == -1:
		if status_types.size() >= MAX_STATUS:
			push_warning("Zu viele verschiedene Status-Effekte (MAX_STATUS)")
			return
		status_types.append(status)
		slot = status_types.size() - 1
	var k := i * MAX_STATUS + slot
	var bit := 1 << slot
	if _status_mask[i] & bit:
		_st_stacks[k] = mini(_st_stacks[k] + 1, status.max_stacks)
	else:
		_st_stacks[k] = 1
		_st_tick[k] = status.tick_interval
		_status_mask[i] |= bit
	_st_left[k] = status.duration


## Status auf alle lebenden Gegner im Umkreis (Debug „Status geben“). Liefert die Anzahl.
func apply_status_in_radius(center: Vector2, radius: float, status: StatusEffectData) -> int:
	var applied := 0
	var radius_sq := radius * radius
	for i in count:
		if _hp[i] > 0.0 and center.distance_squared_to(_positions[i]) <= radius_sq:
			apply_status(i, status)
			applied += 1
	return applied


## Hat Gegner i diesen Status gerade? (Tests, später Elementreaktionen)
func has_status(i: int, status: StatusEffectData) -> bool:
	var slot := status_types.find(status)
	return slot != -1 and (_status_mask[i] & (1 << slot)) != 0


## Stapel eines Status auf Gegner i (0 = nicht aktiv)
func status_stacks(i: int, status: StatusEffectData) -> int:
	if not has_status(i, status):
		return 0
	return _st_stacks[i * MAX_STATUS + status_types.find(status)]


## Status herunterzählen, Schaden über Zeit austeilen, abgelaufene Status entfernen. Nur Gegner mit gesetzter Maske kosten Zeit.
func _update_status(delta: float) -> void:
	for i in count:
		if _status_mask[i] == 0:
			continue
		for slot in status_types.size():
			var bit := 1 << slot
			if not (_status_mask[i] & bit):
				continue
			var status := status_types[slot]
			var k := i * MAX_STATUS + slot
			_st_left[k] -= delta
			if status.kind == StatusEffectData.Kind.DOT and _hp[i] > 0.0:
				_st_tick[k] -= delta
				if _st_tick[k] <= 0.0:
					_st_tick[k] += status.tick_interval
					_apply_damage(i, status.power * _st_stacks[k], status.element, false, true)
			if _st_left[k] <= 0.0:
				_status_mask[i] &= ~bit


## Wie schnell Gegner i laufen darf (1 = normal). Der stärkste aktive Verlangsamungs-Status zählt.
func _speed_factor(i: int) -> float:
	var factor := 1.0
	for slot in status_types.size():
		if _status_mask[i] & (1 << slot):
			var status := status_types[slot]
			if status.kind == StatusEffectData.Kind.SLOW:
				factor = minf(factor, 1.0 - status.power)
			elif status.kind == StatusEffectData.Kind.STOP:
				factor = 0.0
	return factor


## Kettenblitz: Ist Gegner i geschockt, trifft ein Teil von dealt die nächsten Gegner im Umkreis (über das Spatial Grid).
func _chain_from(i: int, dealt: float) -> void:
	for slot in status_types.size():
		if not (_status_mask[i] & (1 << slot)):
			continue
		var status := status_types[slot]
		if status.kind != StatusEffectData.Kind.CHAIN:
			continue
		var found := _nearest_others(i, status.chain_range, mini(status.chain_targets, MAX_CHAIN_TARGETS))
		for n in found:
			var j := _chain_targets[n]
			_add_arc(_positions[i], _positions[j])
			_apply_damage(j, dealt * status.power, status.element, false, false)


## Die nächsten lebenden Gegner (ohne i selbst) im Umkreis max_range um Gegner i, nach Abstand sortiert, nach _chain_targets.
func _nearest_others(i: int, max_range: float, n: int) -> int:
	var found := 0
	var pos := _positions[i]
	var range_sq := max_range * max_range
	var first := _cell_of(pos - Vector2(max_range, max_range))
	var last := _cell_of(pos + Vector2(max_range, max_range))
	for cy in range(first.y, last.y + 1):
		for cx in range(first.x, last.x + 1):
			var j := _cell_head[cy * _grid_size.x + cx]
			while j != -1:
				if j != i and _hp[j] > 0.0:
					var d := pos.distance_squared_to(_positions[j])
					if d <= range_sq and (found < n or d < _chain_distances[n - 1]):
						var k := mini(found, n - 1)
						while k > 0 and _chain_distances[k - 1] > d:
							_chain_distances[k] = _chain_distances[k - 1]
							_chain_targets[k] = _chain_targets[k - 1]
							k -= 1
						_chain_distances[k] = d
						_chain_targets[k] = j
						if found < n:
							found += 1
				j = _cell_next[j]
	return found


func _add_arc(from: Vector2, to: Vector2) -> void:
	if _arc_count >= MAX_ARCS:
		return
	_arc_from[_arc_count] = from - Vector2(0.0, BODY_HEIGHT)
	_arc_to[_arc_count] = to - Vector2(0.0, BODY_HEIGHT)
	_arc_age[_arc_count] = 0.0
	_arc_count += 1


func _update_arcs(delta: float) -> void:
	for a in range(_arc_count - 1, -1, -1):
		_arc_age[a] += delta
		if _arc_age[a] >= ARC_TIME:
			_arc_count -= 1
			_arc_from[a] = _arc_from[_arc_count]
			_arc_to[a] = _arc_to[_arc_count]
			_arc_age[a] = _arc_age[_arc_count]


## Wo Gegner i nach seconds Sekunden voraussichtlich steht: Er läuft geradeaus auf den Helden zu (wie in _move),
## höchstens bis an dessen Rand. Für verzögerte Angriffe (Bomben mit Flug und Zünder).
func predict_position(i: int, seconds: float) -> Vector2:
	var pos := _positions[i]
	if not target:
		return pos
	var data := _type_list[_types[i]]
	var to_target := target.global_position - pos
	var stop_distance := data.radius + target.body_radius + data.attack_range
	var walk := minf(data.speed * seconds, maxf(to_target.length() - stop_distance, 0.0))
	return pos + to_target.normalized() * walk


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


## Die n nächsten lebenden Gegner im Umkreis max_range um pos (Füße), nach Abstand sortiert.
## Schreibt ihre Plätze nach out (Größe wird angepasst) und liefert die Anzahl (höchstens n, höchstens MAX_NEAREST).
## Ein Durchlauf mit kleiner Einfügeliste, ohne neue Arrays. Die Plätze gelten nur bis zum nächsten Entfernen eines Gegners:
## für längeres Merken get_id() nutzen.
func find_nearest_n(pos: Vector2, max_range: float, n: int, out: PackedInt32Array) -> int:
	n = clampi(n, 0, MAX_NEAREST)
	out.resize(n)
	if n == 0:
		return 0
	var found := 0
	var range_sq := max_range * max_range
	for i in count:
		if _hp[i] <= 0.0:
			continue
		var distance_sq := pos.distance_squared_to(_positions[i])
		if distance_sq > range_sq or (found == n and distance_sq >= _nearest_distances[n - 1]):
			continue
		# In die sortierte Liste einfügen, der bisher Fernste fällt heraus, wenn sie voll ist
		var k := mini(found, n - 1)
		while k > 0 and _nearest_distances[k - 1] > distance_sq:
			_nearest_distances[k] = _nearest_distances[k - 1]
			out[k] = out[k - 1]
			k -= 1
		_nearest_distances[k] = distance_sq
		out[k] = i
		if found < n:
			found += 1
	out.resize(found)
	return found


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


## Bis zu n zufällige, verschiedene lebende Gegner, deren Füße im Rechteck area liegen und (bei max_range > 0) höchstens
## max_range von origin entfernt sind. Ein Durchlauf mit „Reservoir Sampling“: jeder passende Gegner hat dieselbe Chance,
## es entstehen keine neuen Arrays. Schreibt die Plätze nach out (Größe wird angepasst) und liefert die Anzahl.
## Nur bei Waffen-Angriffen aufrufen (läuft über alle Gegner), nicht pro Frame.
func pick_random(area: Rect2, origin: Vector2, max_range: float, n: int, out: PackedInt32Array) -> int:
	n = clampi(n, 0, MAX_NEAREST)
	out.resize(n)
	var found := 0
	var seen := 0
	var range_sq := max_range * max_range
	for i in count:
		if _hp[i] <= 0.0 or not area.has_point(_positions[i]):
			continue
		if max_range > 0.0 and origin.distance_squared_to(_positions[i]) > range_sq:
			continue
		seen += 1
		if found < n:
			out[found] = i
			found += 1
		else:
			var j := randi() % seen
			if j < n:
				out[j] = i
	out.resize(found)
	return found


## Alle lebenden Gegner, deren Körperkreis den Kreis (pos, radius) berührt (kreisende Klingen treffen mehrere auf einmal).
## Schreibt ihre Plätze nach out (höchstens out.size() Stück, die Größe bleibt unverändert: kein Neuanlegen pro Frame)
## und liefert die Anzahl. Nutzt das Spatial Grid.
func find_all_in_radius(pos: Vector2, radius: float, out: PackedInt32Array) -> int:
	var found := 0
	var limit := out.size()
	var reach := radius + CELL_SIZE * 0.5
	var first := _cell_of(pos - Vector2(reach, reach))
	var last := _cell_of(pos + Vector2(reach, reach))
	for cy in range(first.y, last.y + 1):
		for cx in range(first.x, last.x + 1):
			var j := _cell_head[cy * _grid_size.x + cx]
			while j != -1:
				if _hp[j] > 0.0:
					var touch := radius + _type_list[_types[j]].radius
					if pos.distance_squared_to(_positions[j]) <= touch * touch:
						out[found] = j
						found += 1
						if found >= limit:
							return found
				j = _cell_next[j]
	return found


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
	_update_status(delta)
	_update_arcs(delta)
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
		_since_hit[i] += delta
		if data.immortal and _since_hit[i] > IMMORTAL_HEAL_DELAY:
			_hp[i] = data.max_hp
		if data.anchored:
			# Übungspuppe: bleibt stehen, wird nicht geschoben, greift nicht an
			continue
		var pos := _positions[i]
		var direction := pos.direction_to(target_pos)
		# Am Rand des Helden bzw. in Angriffsreichweite stehen bleiben
		var contact_distance := data.radius + target_radius
		var stop_distance := contact_distance + data.attack_range
		var target_distance := pos.distance_to(target_pos)
		if target_distance > stop_distance:
			var speed := data.speed * (_speed_factor(i) if _status_mask[i] != 0 else 1.0)
			pos += direction * minf(speed * delta, target_distance - stop_distance)
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
	elif in_range and target and data.contact_damage > 0.0 and target.take_damage(data.contact_damage):
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
	if Settings.show_enemy_health_bars:
		for i in count:
			_draw_health_bar(i)
	_draw_arcs()


## Leiste nur bei verletzten Gegnern, sonst wäre der Bildschirm voller Balken
func _draw_health_bar(i: int) -> void:
	var data := _type_list[_types[i]]
	var max_hp := get_max_hp(i)
	if _hp[i] <= 0.0 or _hp[i] >= max_hp:
		return
	var top := _positions[i] + Vector2(-BAR_FRAME.get_width() * 0.5, 1.0 - data.walk_texture.get_height() * data.draw_scale - BAR_GAP - BAR_FRAME.get_height())
	draw_texture(BAR_FRAME, top.round())
	var width := maxi(1, roundi(BAR_FILL_WIDTH * _hp[i] / max_hp))
	draw_texture_rect_region(BAR_FILL, Rect2(top.round() + Vector2.ONE, Vector2(width, BAR_FILL.get_height())), Rect2(0, 0, width, BAR_FILL.get_height()))


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
	var modulate_color := Color.WHITE
	if _flash[i] > 0.0:
		modulate_color = HIT_FLASH_COLOR
	elif _status_mask[i] != 0:
		modulate_color = _status_tint(i)
	draw_texture_rect_region(texture, frame_rect, source, modulate_color)
	if _status_mask[i] != 0:
		_draw_status_particles(i)


## Tönung in der Elementfarbe. Hat ein Gegner mehrere Status, wechselt die Farbe reihum (alle STATUS_CYCLE Sekunden).
func _status_tint(i: int) -> Color:
	var active := 0
	for slot in status_types.size():
		if _status_mask[i] & (1 << slot):
			active += 1
	var pick := int(_time / STATUS_CYCLE) % active
	for slot in status_types.size():
		if _status_mask[i] & (1 << slot):
			if pick == 0:
				var status := status_types[slot]
				return Color.WHITE.lerp(Elements.damage_color(status.element, false), status.tint)
			pick -= 1
	return Color.WHITE


## Kleine Pixel-Partikel je Status, ohne gespeicherten Zustand: Position und Phase ergeben sich aus Zeit und Gegner-ID.
## Feuer: Funken steigen schnell auf. Gift: Blasen steigen langsam. Kälte: Eiskristalle funkeln. Blitz: Funken zucken.
func _draw_status_particles(i: int) -> void:
	draw_set_transform(_positions[i])
	var id := _ids[i]
	for slot in status_types.size():
		if not (_status_mask[i] & (1 << slot)):
			continue
		var element := status_types[slot].element
		var color := Elements.damage_color(element, false)
		for p in STATUS_PARTICLES:
			var seed_value := id * 7919 + slot * 131 + p * 37
			var x := float(seed_value % 13) - 6.0
			var phase := fposmod(_time * 1.3 + (seed_value % 100) * 0.01, 1.0)
			var size := 1.0
			var y := 0.0
			match element:
				Elements.FIRE:
					phase = fposmod(_time * 1.8 + (seed_value % 100) * 0.01, 1.0)
					y = -6.0 - phase * 22.0
				Elements.POISON:
					y = -4.0 - phase * 16.0
					size = 2.0
				Elements.COLD:
					if phase > 0.5:
						continue
					y = -6.0 - float((seed_value / 13) % 18)
				_:
					# Blitz: alle 0,1 s an einer anderen Stelle aufzucken
					var flick := int(_time * 10.0) + p * 3 + id
					if flick % 3 == 0:
						continue
					x = float((flick * 5) % 15) - 7.0
					y = -4.0 - float((flick * 11) % 22)
			draw_rect(Rect2(Vector2(x, y).round(), Vector2(size, size)), color)
	draw_set_transform(Vector2.ZERO)


## Kettenblitze: kurze gelbe Zickzack-Linie zwischen zwei Gegnern (Körperhöhe), flackert leicht
func _draw_arcs() -> void:
	for a in _arc_count:
		var from := _arc_from[a]
		var to := _arc_to[a]
		var normal := (to - from).orthogonal().normalized()
		var points := PackedVector2Array()
		points.resize(5)
		for k in 5:
			var t := k / 4.0
			var jitter := 0.0
			if k > 0 and k < 4:
				jitter = 3.0 if (k + int(_time * 30.0)) % 2 == 0 else -3.0
			points[k] = from.lerp(to, t) + normal * jitter
		draw_polyline(points, ARC_COLOR, 1.0)
