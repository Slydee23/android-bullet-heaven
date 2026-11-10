extends SceneTree
## Erzeugt Waldboden, Details, Kronendach und Waldrand als echte 32×32-Pixel-Art (kein Skalieren).

## Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_forest.gd
## Schreibt die Texturen nach assets/tiles/, Vorschaubilder nach user://forest_preview/.
const OUT := "res://assets/tiles/"
const PREVIEW := "user://forest_preview/"
const PROJ := "res://"
const S := 128  # Kronendach: 4×4 Tiles
const G := 512  # Boden: 16×16 Tiles (Wiederholung erst alle 512 px)
var ns := S  # aktuelle Rauschgröße
## Anteil der Bodenfläche, der Erde statt Moos ist (0,15 = 15 %). Die Schwelle wird daraus berechnet.
const SOIL_SHARE := 0.15
## Wie stark die Fleckformen verzerrt werden (in Pixeln): größer = wildere, ausgefranste Flecken
const WARP_PX := 28.0
var soil_pixels := 0

# Palette
var SOIL := [Color.html("#251c16"), Color.html("#33271d"), Color.html("#443426")]
var MOSS := [Color.html("#223020"), Color.html("#2d3f27"), Color.html("#3b5230"), Color.html("#56693c")]
var CANOPY := [Color.html("#0a120e"), Color.html("#122019"), Color.html("#1a2d20"), Color.html("#253f27"), Color.html("#365432")]
var BUSH := [Color.html("#121c14"), Color.html("#1e2e1d"), Color.html("#2b4126"), Color.html("#3b5530"), Color.html("#536c3a")]
var BARK := [Color.html("#1e140f"), Color.html("#2f2017"), Color.html("#45301f"), Color.html("#5a4029")]
var STONE := [Color.html("#36353c"), Color.html("#525059"), Color.html("#747079")]
var LEAF := [Color.html("#5e3519"), Color.html("#814d22"), Color.html("#a3722f")]
var SHADOW := Color(0, 0, 0, 0.35)

var rng := RandomNumberGenerator.new()
var lattices := {}


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PREVIEW))
	# Jede Textur hat ihren eigenen festen Zufallswert: Eine Änderung an einer verändert die anderen nicht
	rng.seed = 23
	var ground := _ground()
	ground.save_png(OUT + "forest_ground.png")
	rng.seed = 24
	var details := _details()
	details.save_png(OUT + "forest_ground_details.png")
	rng.seed = 25
	var canopy := _canopy()
	canopy.save_png(OUT + "forest_canopy.png")
	rng.seed = 26
	var edge := _edge()
	edge.save_png(OUT + "forest_edge.png")
	rng.seed = 27
	_preview(ground, details, canopy, edge)
	print("ok")
	quit()


# ---------- periodisches Rauschen (nahtlos über S) ----------

func _lattice(period: int, seed_value: int) -> PackedFloat32Array:
	var key := period * 1000 + seed_value
	if lattices.has(key):
		return lattices[key]
	var r := RandomNumberGenerator.new()
	r.seed = key
	var arr := PackedFloat32Array()
	arr.resize(period * period)
	for i in arr.size():
		arr[i] = r.randf()
	lattices[key] = arr
	return arr


func _noise(x: float, y: float, period: int, seed_value: int) -> float:
	var lat := _lattice(period, seed_value)
	var fx := x / ns * period
	var fy := y / ns * period
	var ix := int(floor(fx))
	var iy := int(floor(fy))
	var tx := smoothstep(0.0, 1.0, fx - ix)
	var ty := smoothstep(0.0, 1.0, fy - iy)
	var x0 := posmod(ix, period)
	var x1 := posmod(ix + 1, period)
	var y0 := posmod(iy, period)
	var y1 := posmod(iy + 1, period)
	var a := lerpf(lat[y0 * period + x0], lat[y0 * period + x1], tx)
	var b := lerpf(lat[y1 * period + x0], lat[y1 * period + x1], tx)
	return lerpf(a, b, ty)


func _wset(img: Image, x: int, y: int, c: Color) -> void:
	img.set_pixel(posmod(x, img.get_width()), posmod(y, img.get_height()), c)


func _wget(img: Image, x: int, y: int) -> Color:
	return img.get_pixel(posmod(x, img.get_width()), posmod(y, img.get_height()))


# ---------- Boden ----------

func _ground() -> Image:
	ns = G
	var img := Image.create(G, G, false, Image.FORMAT_RGBA8)
	var moss := []
	moss.resize(G * G)
	var rim: Color = MOSS[2].lerp(MOSS[3], 0.45)
	# 1. Rauschwerte mit verzerrten Koordinaten (Domain Warping): bricht runde, rasterförmige Blobs auf
	var values := PackedFloat32Array()
	values.resize(G * G)
	for y in G:
		for x in G:
			var wx := (_noise(x, y, 8, 11) - 0.5) * 2.0 * WARP_PX + (_noise(x, y, 32, 13) - 0.5) * WARP_PX * 0.5
			var wy := (_noise(x, y, 8, 12) - 0.5) * 2.0 * WARP_PX + (_noise(x, y, 32, 14) - 0.5) * WARP_PX * 0.5
			var px := x + wx
			var py := y + wy
			var m := 0.4 * _noise(px, py, 8, 1) + 0.3 * _noise(px, py, 16, 2) + 0.2 * _noise(px, py, 32, 3) + 0.1 * _noise(px, py, 64, 5)
			# kleines Pixelrauschen: ausgefranste statt glatter Ränder
			values[y * G + x] = m + (rng.randf() - 0.5) * 0.025
	# 2. Schwelle so wählen, dass genau SOIL_SHARE der Fläche Erde ist
	var sorted := values.duplicate()
	sorted.sort()
	var soil_threshold := sorted[int(SOIL_SHARE * sorted.size())]
	for y in G:
		for x in G:
			var m := values[y * G + x]
			var t := _noise(x, y, 128, 4) - 0.5
			var is_moss := m > soil_threshold
			moss[y * G + x] = is_moss
			if not is_moss:
				soil_pixels += 1
			var c: Color
			if is_moss:
				var v := m + t * 0.16
				c = MOSS[2] if v > 0.6 else (MOSS[1] if v > 0.49 else MOSS[0])
			else:
				# Erdflecken: innen dunkler, zum Moos hin heller
				var v := m + t * 0.12
				c = SOIL[2] if v > soil_threshold - 0.04 else (SOIL[1] if v > soil_threshold - 0.12 else SOIL[0])
			img.set_pixel(x, y, c)
	print("Erdanteil Boden: %d %%" % roundi(100.0 * soil_pixels / (G * G)))
	# Kanten: Moos-Oberkante etwas heller, Erde unter dem Moos im Schatten
	for y in G:
		for x in G:
			var here: bool = moss[y * G + x]
			var above: bool = moss[posmod(y - 1, G) * G + x]
			if here and not above:
				img.set_pixel(x, y, rim)
			elif not here and above:
				img.set_pixel(x, y, SOIL[0])
	# Grasbüschel (vor allem auf Moos)
	for i in 560 * 4:  # Fläche ×4 gegenüber früher 256 px
		var x := rng.randi_range(0, G - 1)
		var y := rng.randi_range(0, G - 1)
		var on_moss: bool = moss[y * G + x]
		if not on_moss and rng.randf() < 0.8:
			continue
		_tuft(img, x, y, rng.randi_range(2, 3))
	# Steinchen und Zweigreste auf der Erde
	for i in 220 * 4:
		var x := rng.randi_range(0, G - 1)
		var y := rng.randi_range(0, G - 1)
		if moss[y * G + x]:
			continue
		if rng.randf() < 0.7:
			_wset(img, x, y, STONE[1])
			if rng.randf() < 0.5:
				_wset(img, x + 1, y, STONE[0])
			if rng.randf() < 0.4:
				_wset(img, x, y - 1, STONE[2])
		else:
			_wset(img, x, y, SOIL[2].lightened(0.12))
			_wset(img, x + 1, y + (1 if rng.randf() < 0.5 else 0), SOIL[2].lightened(0.12))
	ns = S
	return img


func _tuft(img: Image, x: int, y: int, blades: int) -> void:
	for b in blades:
		var bx := x + b - blades / 2
		var h := rng.randi_range(2, 3)
		for k in h:
			_wset(img, bx, y - k, MOSS[3] if k == h - 1 else MOSS[2])
	_wset(img, x, y + 1, MOSS[0])


# ---------- Details (transparent) ----------

func _details() -> Image:
	var img := Image.create(32 * 7, 32, false, Image.FORMAT_RGBA8)
	# 0 Steine
	_stone(img, 9, 14, 4, 3)
	_stone(img, 16, 19, 3, 2)
	_stone(img, 21, 13, 2, 2)
	# 1 Laub
	var leaf_spots := [Vector2i(8, 10), Vector2i(14, 15), Vector2i(20, 9), Vector2i(11, 21), Vector2i(22, 19), Vector2i(17, 24)]
	for p in leaf_spots:
		_leaf(img, 32 + p.x, p.y)
	# 2 Pilze
	_mushroom(img, 64 + 12, 18, 4)
	_mushroom(img, 64 + 18, 21, 3)
	_mushroom(img, 64 + 21, 15, 2)
	# 3 Blumen
	_flower(img, 96 + 9, 12, Color.html("#8fa2c8"))
	_flower(img, 96 + 17, 18, Color.html("#c9c3d9"))
	_flower(img, 96 + 22, 11, Color.html("#8fa2c8"))
	_flower(img, 96 + 12, 23, Color.html("#c9c3d9"))
	# 4 Zweig
	for i in 12:
		img.set_pixel(128 + 9 + i, 20 - i / 3, BARK[2] if i % 4 else BARK[3])
		img.set_pixel(128 + 9 + i, 21 - i / 3, BARK[0])
	for i in 4:
		img.set_pixel(128 + 15 + i, 17 - i - 1, BARK[2])
	img.set_pixel(128 + 19, 12, MOSS[3])
	img.set_pixel(128 + 20, 12, MOSS[2])
	# 5 Farn
	_fern(img, 160 + 16, 22)
	# 6 Wurzel
	for i in 16:
		var yy := 17 + int(round(sin(i * 0.35) * 2.0))
		img.set_pixel(192 + 8 + i, yy, BARK[2] if i % 3 else BARK[3])
		img.set_pixel(192 + 8 + i, yy + 1, BARK[0])
	img.set_pixel(192 + 12, 15, BARK[2])
	img.set_pixel(192 + 12, 14, BARK[1])
	return img


func _stone(img: Image, cx: int, cy: int, w: int, h: int) -> void:
	for x in range(-w / 2 - 1, w / 2 + 2):
		img.set_pixel(cx + x, cy + h, SHADOW)
	for y in h:
		for x in w:
			var c: Color = STONE[1]
			if y == 0 or x == 0:
				c = STONE[2]
			if y == h - 1 or x == w - 1:
				c = STONE[0]
			img.set_pixel(cx - w / 2 + x, cy + y, c)


func _leaf(img: Image, x: int, y: int) -> void:
	var c: Color = LEAF[rng.randi_range(0, 2)]
	img.set_pixel(x, y, c)
	img.set_pixel(x + 1, y, c.darkened(0.2))
	if rng.randf() < 0.6:
		img.set_pixel(x, y + 1, c.darkened(0.3))


func _mushroom(img: Image, x: int, y: int, w: int) -> void:
	img.set_pixel(x, y + 2, SHADOW)
	img.set_pixel(x + 1, y + 2, SHADOW)
	img.set_pixel(x, y + 1, Color.html("#cbbf9f"))
	img.set_pixel(x, y, Color.html("#b5a985"))
	for i in w:
		var cx := x - w / 2 + i
		img.set_pixel(cx, y - 1, Color.html("#7a2b25"))
		if w > 2:
			img.set_pixel(cx, y - 2, Color.html("#93352c") if i > 0 and i < w - 1 else Color.TRANSPARENT)
	img.set_pixel(x - w / 2 + 1, y - 1, Color.html("#d8ccae"))


func _flower(img: Image, x: int, y: int, petal: Color) -> void:
	img.set_pixel(x, y + 1, MOSS[2])
	img.set_pixel(x, y + 2, MOSS[1])
	img.set_pixel(x, y, Color.html("#d6b54e"))
	img.set_pixel(x - 1, y, petal)
	img.set_pixel(x + 1, y, petal)
	img.set_pixel(x, y - 1, petal)


func _fern(img: Image, x: int, y: int) -> void:
	var dirs := [Vector2(-1, -0.5), Vector2(-0.6, -1), Vector2(0, -1), Vector2(0.6, -1), Vector2(1, -0.5)]
	for d in dirs:
		for k in 7:
			var p: Vector2 = Vector2(x, y) + d * k
			img.set_pixel(int(p.x), int(p.y), MOSS[3] if k > 4 else MOSS[2])
	for i in range(-3, 4):
		img.set_pixel(x + i, y + 1, SHADOW)


# ---------- Kronendach (nahtlos) ----------

func _canopy() -> Image:
	var img := Image.create(S, S, false, Image.FORMAT_RGBA8)
	img.fill(CANOPY[0])
	var crowns := []
	for i in 95:
		crowns.append(Vector3(rng.randf() * S, rng.randf() * S, rng.randf_range(8.0, 14.0)))
	crowns.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.y < b.y)
	for c in crowns:
		_crown(img, c.x, c.y, c.z, CANOPY, true)
	return img


## Baumkrone von schräg oben: oben links Licht, unten dunkler Rand, Blattbüschel über Rauschen.
func _crown(img: Image, cx: float, cy: float, r: float, pal: Array, wrap: bool) -> void:
	var seed_value := rng.randi_range(10, 999)
	for y in range(int(cy - r - 1), int(cy + r + 2)):
		for x in range(int(cx - r - 1), int(cx + r + 2)):
			var dx := (x + 0.5 - cx) / r
			var dy := (y + 0.5 - cy) / r
			var bump := (_noise(x * 2.0, y * 2.0, 16, seed_value) - 0.5) * 0.35
			var d := sqrt(dx * dx + dy * dy * 1.1) + bump
			if d > 1.0:
				continue
			if not wrap and (x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height()):
				continue
			var light := 0.55 - dx * 0.25 - dy * 0.45 + (_noise(x * 3.0, y * 3.0, 32, seed_value + 1) - 0.5) * 0.5
			var c: Color
			if d > 0.88 and dy > 0.1:
				c = pal[0]
			elif light > 0.85:
				c = pal[4]
			elif light > 0.62:
				c = pal[3]
			elif light > 0.38:
				c = pal[2]
			else:
				c = pal[1]
			if wrap:
				_wset(img, x, y, c)
			else:
				img.set_pixel(x, y, c)


# ---------- Waldrand-Stücke (transparent, je 32×32, Fußpunkt unten Mitte) ----------

func _piece(n: int) -> Image:
	var p := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	match n:
		0:
			_crown(p, 16, 17, 13.5, CANOPY, false)
		1:
			_crown(p, 10, 13, 8, CANOPY, false)
			_crown(p, 17, 18, 12.5, CANOPY, false)
		2:
			_crown(p, 11, 18, 10, CANOPY, false)
			_crown(p, 21, 17, 10.5, CANOPY, false)
		3:
			_crown(p, 22, 11, 8, CANOPY, false)
			_crown(p, 15, 19, 11.5, CANOPY, false)
		4:
			_crown(p, 11, 24, 8, BUSH, false)
			_crown(p, 21, 23, 8.5, BUSH, false)
			_crown(p, 16, 20, 7, BUSH, false)
		5:
			_crown(p, 16, 22, 9.5, BUSH, false)
			for b in [Vector2i(12, 20), Vector2i(19, 18), Vector2i(17, 25)]:
				p.set_pixel(b.x, b.y, Color.html("#8a2e2e"))
				p.set_pixel(b.x, b.y - 1, Color.html("#b5534a"))
		6, 7:
			# Baum mit Stamm (für den oberen Rand: man schaut von vorne in den Wald)
			for x in range(9, 24):
				p.set_pixel(x, 31, SHADOW)
			for x in range(7, 26):
				if abs(x - 16) < 8:
					p.set_pixel(x, 30, SHADOW)
			var tx := 14 if n == 6 else 13
			for y in range(18, 30):
				for x in range(tx, tx + 4):
					var c: Color = BARK[2]
					if x == tx:
						c = BARK[3]
					elif x == tx + 3:
						c = BARK[0]
					elif (y + x) % 5 == 0:
						c = BARK[1]
					p.set_pixel(x, y, c)
			p.set_pixel(tx - 1, 29, BARK[1])
			p.set_pixel(tx + 4, 29, BARK[0])
			p.set_pixel(tx - 2, 30, BARK[1])
			if n == 6:
				_crown(p, 16, 11, 11, CANOPY, false)
			else:
				_crown(p, 13, 12, 9, CANOPY, false)
				_crown(p, 20, 13, 9, CANOPY, false)
		8:
			# Schattenstreifen unter dem oberen Waldrand (oben dunkel, nach unten auslaufend)
			for y in 32:
				var a := 0.6 * pow(1.0 - y / 31.0, 1.5)
				for x in 32:
					p.set_pixel(x, y, Color(0, 0, 0, a))
	return p


func _edge() -> Image:
	var img := Image.create(32 * 9, 32, false, Image.FORMAT_RGBA8)
	for n in 9:
		img.blit_rect(_piece(n), Rect2i(0, 0, 32, 32), Vector2i(n * 32, 0))
	return img


# ---------- Vorschau ----------

func _preview(ground: Image, details: Image, canopy: Image, edge: Image) -> void:
	# Kleine Map: begehbar 12×7 Kacheln, Waldgürtel 3 Kacheln
	var F := 3
	var walk := Vector2i(18, 9)
	var tiles := walk + Vector2i(F, F) * 2
	var img := Image.create(tiles.x * 32, tiles.y * 32, false, Image.FORMAT_RGBA8)
	var w := Rect2i(F * 32, F * 32, walk.x * 32, walk.y * 32)
	for ty in tiles.y:
		for tx in tiles.x:
			img.blit_rect(ground, Rect2i((tx % 8) * 32, (ty % 8) * 32, 32, 32), Vector2i(tx * 32, ty * 32))
			var inside := tx >= F and tx < F + walk.x and ty >= F and ty < F + walk.y
			if inside and rng.randf() < 0.12:
				img.blend_rect(details, Rect2i(rng.randi_range(0, 6) * 32, 0, 32, 32), Vector2i(tx * 32, ty * 32))
	for ty in tiles.y:
		for tx in tiles.x:
			var inside := tx >= F and tx < F + walk.x and ty >= F - 1 and ty < F + walk.y
			if not inside:
				img.blit_rect(canopy, Rect2i((tx % 4) * 32, (ty % 4) * 32, 32, 32), Vector2i(tx * 32, ty * 32))
	var back := []
	var front := []
	# oben: Schatten, hintere Kronen, Bäume mit Stamm
	for tx in range(F - 1, F + walk.x + 1):
		back.append([8, Vector2i(tx * 32 + 16, w.position.y), false, -1000])
	var x := w.position.x - 24
	while x < w.end.x + 24:
		back.append([rng.randi_range(0, 3), Vector2i(x, w.position.y - 14 + rng.randi_range(-4, 4)), rng.randf() < 0.5, 0])
		x += rng.randi_range(16, 22)
	x = w.position.x - 16
	while x < w.end.x + 16:
		back.append([rng.randi_range(6, 7), Vector2i(x, w.position.y + rng.randi_range(0, 3)), rng.randf() < 0.5, 0])
		x += rng.randi_range(17, 24)
	# links/rechts
	var y := w.position.y - 8
	while y < w.end.y + 24:
		back.append([rng.randi_range(0, 3), Vector2i(w.position.x - 3 + rng.randi_range(-4, 3), y + 16), rng.randf() < 0.5, 0])
		back.append([rng.randi_range(0, 3), Vector2i(w.end.x + 3 + rng.randi_range(-3, 4), y + 16), rng.randf() < 0.5, 0])
		if rng.randf() < 0.5:
			back.append([rng.randi_range(0, 3), Vector2i(w.position.x - 20, y + 8), rng.randf() < 0.5, 0])
		y += rng.randi_range(16, 20)
	# unten (vor den Figuren)
	x = w.position.x - 24
	while x < w.end.x + 24:
		var bush := rng.randf() < 0.3
		var n := rng.randi_range(4, 5) if bush else rng.randi_range(0, 3)
		var base := w.end.y + (8 if bush else 18) + rng.randi_range(-3, 3)
		front.append([n, Vector2i(x, base), rng.randf() < 0.5, 0])
		x += rng.randi_range(15, 20)
	var by_y := func(a: Array, b: Array) -> bool: return a[1].y + a[3] < b[1].y + b[3]
	back.sort_custom(by_y)
	front.sort_custom(by_y)
	for p in back:
		_stamp(img, edge, p)
	# Figuren
	var hero := Image.load_from_file(ProjectSettings.globalize_path(PROJ + "assets/sprites/characters/hero_idle.png"))
	var skel := Image.load_from_file(ProjectSettings.globalize_path(PROJ + "assets/sprites/enemies/skeleton_walk.png"))
	img.blend_rect(hero, Rect2i(0, 0, 32, 32), Vector2i(w.position.x + 150, w.position.y + 90))
	for i in 4:
		img.blend_rect(skel, Rect2i(i * 32, 0, 32, 32), Vector2i(w.position.x + 40 + i * 70, w.end.y - 34 + (i % 2) * 6))
	img.blend_rect(skel, Rect2i(0, 0, 32, 32), Vector2i(w.position.x + 260, w.position.y - 6))
	for p in front:
		_stamp(img, edge, p)
	img.resize(img.get_width() * 2, img.get_height() * 2, Image.INTERPOLATE_NEAREST)
	img.save_png(PREVIEW + "preview_map.png")
	# Nahtlos-Test: Boden und Kronendach 2×2 gekachelt
	var sheet := Image.create(G * 2, G * 2, false, Image.FORMAT_RGBA8)
	for i in 4:
		sheet.blit_rect(ground, Rect2i(0, 0, G, G), Vector2i((i % 2) * G, (i / 2) * G))
	sheet.resize(sheet.get_width(), sheet.get_height(), Image.INTERPOLATE_NEAREST)
	sheet.save_png(PREVIEW + "preview_tiling.png")
	var e := edge.duplicate()
	var dets := details.duplicate()
	var both := Image.create(32 * 9, 64, false, Image.FORMAT_RGBA8)
	both.fill(SOIL[1])
	both.blend_rect(e, Rect2i(0, 0, 32 * 9, 32), Vector2i.ZERO)
	both.blend_rect(dets, Rect2i(0, 0, 32 * 7, 32), Vector2i(0, 32))
	both.resize(both.get_width() * 4, both.get_height() * 4, Image.INTERPOLATE_NEAREST)
	both.save_png(PREVIEW + "preview_pieces.png")


func _stamp(img: Image, edge: Image, p: Array) -> void:
	var piece := edge.get_region(Rect2i(p[0] * 32, 0, 32, 32))
	if p[2]:
		piece.flip_x()
	var pos: Vector2i = p[1] - Vector2i(16, 32)
	img.blend_rect(piece, Rect2i(0, 0, 32, 32), pos)
