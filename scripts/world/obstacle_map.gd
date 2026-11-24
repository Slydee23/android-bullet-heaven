class_name ObstacleMap
extends RefCounted
## Alle Hindernisse eines Runs in einem groben Raster (wird einmal beim Start gebaut, danach nur gelesen).
## Zwei Sichten auf dieselben Hindernisse:
## - Kollision: die genauen Kreise der Form (ein Stamm sind mehrere Kreise). Nichts steckt je in einem Hindernis.
## - Ausweichen: jedes Hindernis als ein Umriss-Kreis um die ganze Form. Gegner laufen außen herum und geraten so nicht in
##   die Nischen zwischen den Kreisen einer Form (dort würden sie von zwei Seiten gleichzeitig gedrückt und hängen bleiben).
## Heiße Abfragen (pro Gegner und Frame) schauen nur in eine Rasterzelle. Die meisten sind leer, dann kostet es fast nichts.

## Größe einer Rasterzelle (Welt-Pixel)
const CELL := 64.0
## Ab diesem Abstand (zusätzlich zu den Radien) lenken Gegner seitlich um ein Hindernis herum
const AVOID_MARGIN := 24.0
## Größter Körper-Radius, der abgefragt wird (Boss), für das Eintragen ins Raster
const MAX_BODY_RADIUS := 24.0
## Versuche, einen zufälligen Platz für ein Hindernis zu finden
const PLACE_ATTEMPTS := 40

## Kollisions-Kreise aller Hindernisse (Mittelpunkt, Radius) und zu welchem Hindernis sie gehören (Index in kinds)
var centers := PackedVector2Array()
var radii := PackedFloat32Array()
var circle_kind := PackedInt32Array()
## Platzierte Hindernisse: Art, Mittelpunkt und Umriss-Radius der ganzen Form
var kinds: Array[ObstacleKind] = []
var positions := PackedVector2Array()
var extents := PackedFloat32Array()
## Welche Grafik-Variante jedes Hindernis zeigt (ergibt sich aus der Position, gleiche Karte = gleiche Bilder)
var variants := PackedInt32Array()

var _area := Rect2()
var _grid_size := Vector2i.ZERO
## Je Zelle: Kollisions-Kreise (Index in centers) bzw. Hindernisse (Index in positions)
var _circle_cells: Array[PackedInt32Array] = []
var _object_cells: Array[PackedInt32Array] = []
var _empty := PackedInt32Array()


## Baut die Hindernisse der Karte in der begehbaren Fläche area. seed_value bestimmt die zufälligen
## (gleicher Wert = gleiche Karte, z. B. beim Fortsetzen eines Runs).
func build(map: MapData, area: Rect2, seed_value: int) -> void:
	_area = area
	centers.clear()
	radii.clear()
	circle_kind.clear()
	kinds.clear()
	positions.clear()
	extents.clear()
	variants.clear()
	if map:
		for placement in map.fixed:
			if placement and placement.kind:
				_add(placement.kind, area.position + placement.position)
		_place_random(map, seed_value)
	_build_grid()


## Zahl der Hindernisse (nicht der Kreise)
func count() -> int:
	return positions.size()


func _place_random(map: MapData, seed_value: int) -> void:
	if map.random_kinds.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var center := _area.get_center()
	for n in map.random_count:
		var kind := _pick_kind(map.random_kinds, rng)
		var extent := kind.extent()
		var inner := _area.grow(-(map.edge_margin + extent))
		if inner.size.x <= 0.0 or inner.size.y <= 0.0:
			return
		for attempt in PLACE_ATTEMPTS:
			var pos := inner.position + Vector2(rng.randf() * inner.size.x, rng.randf() * inner.size.y)
			if pos.distance_to(center) < map.center_clear + extent:
				continue
			if _fits(extent, pos, map.min_gap):
				_add(kind, pos)
				break


## Hält ein Hindernis mit Umriss extent an pos den Mindestabstand zu allen anderen Umrissen? (nur beim Aufbau)
## Abstand zwischen Umrissen: So bleibt zwischen zwei Hindernissen immer ein Durchgang.
func _fits(extent: float, pos: Vector2, gap: float) -> bool:
	for k in positions.size():
		var min_distance := extents[k] + extent + gap
		if pos.distance_squared_to(positions[k]) < min_distance * min_distance:
			return false
	return true


func _pick_kind(list: Array[ObstacleKind], rng: RandomNumberGenerator) -> ObstacleKind:
	var total := 0.0
	for kind in list:
		total += kind.weight
	var pick := rng.randf() * total
	for kind in list:
		if pick < kind.weight:
			return kind
		pick -= kind.weight
	return list[list.size() - 1]


func _add(kind: ObstacleKind, pos: Vector2) -> void:
	var kind_index := kinds.size()
	kinds.append(kind)
	positions.append(pos)
	extents.append(kind.extent())
	# Variante aus der Position: hängt nicht vom Zufallsgenerator ab und bleibt beim Fortsetzen gleich
	variants.append(absi(roundi(pos.x) * 7 + roundi(pos.y) * 13) % maxi(kind.variants, 1))
	for c in kind.circles:
		centers.append(pos + Vector2(c.x, c.y))
		radii.append(c.z)
		circle_kind.append(kind_index)


func _build_grid() -> void:
	_grid_size = Vector2i((_area.size / CELL).ceil()) + Vector2i.ONE
	_circle_cells = _new_cells()
	_object_cells = _new_cells()
	for k in centers.size():
		_register(_circle_cells, k, centers[k], radii[k] + MAX_BODY_RADIUS)
	for k in positions.size():
		_register(_object_cells, k, positions[k], extents[k] + MAX_BODY_RADIUS + AVOID_MARGIN)


func _new_cells() -> Array[PackedInt32Array]:
	var cells: Array[PackedInt32Array] = []
	cells.resize(_grid_size.x * _grid_size.y)
	for k in cells.size():
		cells[k] = PackedInt32Array()
	return cells


## Trägt index in alle Zellen ein, die der Kreis um center mit Radius reach berührt
func _register(cells: Array[PackedInt32Array], index: int, center: Vector2, reach: float) -> void:
	var from := _cell_coords(center - Vector2(reach, reach))
	var to := _cell_coords(center + Vector2(reach, reach))
	for y in range(from.y, to.y + 1):
		for x in range(from.x, to.x + 1):
			cells[y * _grid_size.x + x].append(index)


func _cell_coords(pos: Vector2) -> Vector2i:
	var local := ((pos - _area.position) / CELL).floor()
	return Vector2i(clampi(int(local.x), 0, _grid_size.x - 1), clampi(int(local.y), 0, _grid_size.y - 1))


func _cell_index(pos: Vector2) -> int:
	var cell := _cell_coords(pos)
	return cell.y * _grid_size.x + cell.x


## Schiebt einen Körper (Radius radius) aus allen Kollisions-Kreisen heraus. Weil nur radial geschoben wird,
## gleitet ein Körper, der schräg gegen ein Hindernis läuft, daran entlang.
func push_out(pos: Vector2, radius: float) -> Vector2:
	if _circle_cells.is_empty():
		return pos
	for k in _circle_cells[_cell_index(pos)]:
		var offset := pos - centers[k]
		var min_distance := radii[k] + radius
		var distance_sq := offset.length_squared()
		if distance_sq < min_distance * min_distance:
			var distance := sqrt(distance_sq)
			pos = centers[k] + (offset / distance if distance > 0.001 else Vector2.RIGHT) * min_distance
	return pos


## Lenkt eine Laufrichtung seitlich an Hindernissen vorbei, die vor dem Körper liegen (einfaches Ausweichen statt Wegsuche).
## Nutzt den Umriss jedes Hindernisses. Ergebnis ist wieder eine Einheitsrichtung.
func steer(pos: Vector2, direction: Vector2, radius: float) -> Vector2:
	if _object_cells.is_empty():
		return direction
	var near := _object_cells[_cell_index(pos)]
	if near.is_empty():
		return direction
	var result := direction
	for k in near:
		var to_center := positions[k] - pos
		var reach := extents[k] + radius + AVOID_MARGIN
		var distance_sq := to_center.length_squared()
		if distance_sq > reach * reach or distance_sq < 0.001:
			continue
		var distance := sqrt(distance_sq)
		var toward := to_center / distance
		var ahead := direction.dot(toward)
		if ahead <= 0.0:
			continue
		# Seitlich vorbei, auf der Seite, zu der die Laufrichtung ohnehin schon zeigt
		var side := Vector2(-toward.y, toward.x)
		if side.dot(direction) < 0.0:
			side = -side
		var closeness := clampf(1.0 - (distance - extents[k] - radius) / AVOID_MARGIN, 0.0, 1.0)
		result += side * ahead * (0.6 + closeness)
		# Je näher, desto weniger weiter direkt aufs Hindernis zu
		result -= toward * ahead * closeness
	return result.normalized() if result.length_squared() > 0.0001 else direction


## Ist an pos Platz für einen Körper mit Radius radius?
func is_free(pos: Vector2, radius: float) -> bool:
	if _circle_cells.is_empty():
		return true
	for k in _circle_cells[_cell_index(pos)]:
		var min_distance := radii[k] + radius
		if pos.distance_squared_to(centers[k]) < min_distance * min_distance:
			return false
	return true


## Liegt pos in einem Hindernis? (z. B. Feuerbälle zerplatzen daran)
func blocks(pos: Vector2) -> bool:
	return not is_free(pos, 0.0)
