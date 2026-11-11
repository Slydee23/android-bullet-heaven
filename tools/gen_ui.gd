extends SceneTree
## Erzeugt die UI-Texturen im Stil „Runenstein & Bann-Siegel“ und das Hauptmenü-Bild als echte Pixel-Art.
## Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_ui.gd
## Schreibt nach assets/ui/. Alle Dateien lassen sich durch eigene Alpha-Assets (gleicher Name, gleiche Größe) ersetzen.

const OUT := "res://assets/ui/"
const HERO := "res://assets/sprites/characters/hero_idle.png"

# Palette: dunkler Runenstein, Gold, violetter Magie-Schimmer
const OUTLINE := Color("#0a0710")
const STONE_HI := Color("#6a5b8c")
const STONE_LIGHT := Color("#4a3f66")
const STONE := Color("#35294d")
const STONE_DARK := Color("#2a2240")
const STONE_DEEP := Color("#1c1629")
const FILL := Color("#17121f")
const GOLD_HI := Color("#f6dc90")
const GOLD := Color("#e0b050")
const GOLD_MID := Color("#a87a2a")
const GOLD_DARK := Color("#6b4a1a")
const VIOLET_HI := Color("#b49cff")
const VIOLET := Color("#7a5cd0")
const VIOLET_DARK := Color("#4a2f8c")
const CREAM :=Color("#e8ddc7")

var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.seed = 28
	_panel().save_png(OUT + "panel.png")
	_button(false).save_png(OUT + "button.png")
	_button(true).save_png(OUT + "button_pressed.png")
	_slider_track().save_png(OUT + "slider_track.png")
	_slider_grabber().save_png(OUT + "slider_grabber.png")
	_icon_button("pause").save_png(OUT + "pause_button.png")
	_icon_button("debug").save_png(OUT + "debug_button.png")
	_divider().save_png(OUT + "divider.png")
	_menu_background().save_png(OUT + "menu_background.png")
	print("ok")
	quit()


# ---------- Hilfsfunktionen ----------

func _new(w: int, h: int) -> Image:
	return Image.create_empty(w, h, false, Image.FORMAT_RGBA8)


func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)


## Wie _px, aber mischt halbtransparente Farben über das vorhandene Pixel
func _blend(img: Image, x: int, y: int, c: Color) -> void:
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return
	var old := img.get_pixel(x, y)
	img.set_pixel(x, y, Color(old.r, old.g, old.b, 1.0).lerp(Color(c.r, c.g, c.b, 1.0), c.a))


## Ring-Nummer eines Pixels von außen nach innen (0 = äußerster Rand), -1 = außerhalb der abgerundeten Ecke.
func _ring(x: int, y: int, w: int, h: int, radius: int) -> int:
	var dx := mini(x, w - 1 - x)
	var dy := mini(y, h - 1 - y)
	if dx < radius and dy < radius:
		var dist := Vector2(radius - (dx + 0.5), radius - (dy + 0.5)).length()
		if dist > radius:
			return -1
		return int(floor(radius - dist))
	return mini(dx, dy)


## true, wenn das Pixel auf der beleuchteten Seite liegt (oben/links), sonst Schattenseite (unten/rechts)
func _lit(x: int, y: int, w: int, h: int) -> bool:
	var dx := mini(x, w - 1 - x)
	var dy := mini(y, h - 1 - y)
	if dy < dx:
		return y < h / 2
	if dx < dy:
		return x < w / 2
	return (x + y) < (w + h) / 2


## Zeichnet einen Rahmen aus Ringen. layers[i] = [Licht-Farbe, Schatten-Farbe] für Ring i, danach Füllung.
func _frame(w: int, h: int, radius: int, layers: Array, fill: Color) -> Image:
	var img := _new(w, h)
	for y in h:
		for x in w:
			var r := _ring(x, y, w, h, radius)
			if r < 0:
				continue
			if r < layers.size():
				img.set_pixel(x, y, layers[r][0] if _lit(x, y, w, h) else layers[r][1])
			else:
				img.set_pixel(x, y, fill)
	return img


# ---------- Fenster, Knöpfe, Regler ----------

## 24×24, 9-Slice mit Rand 8: Steinrahmen mit goldener Linie und Nieten in den Ecken
func _panel() -> Image:
	var layers := [
		[OUTLINE, OUTLINE],
		[STONE_HI, STONE_DEEP],
		[STONE_LIGHT, STONE_DARK],
		[STONE, STONE_DARK],
		[GOLD, GOLD_DARK],
		[Color("#100c18"), Color("#100c18")],
		[STONE_DEEP, STONE_DEEP],
	]
	var img := _frame(24, 24, 4, layers, FILL)
	# Goldene Nieten in allen vier Ecken
	for corner in [Vector2i(3, 3), Vector2i(20, 3), Vector2i(3, 20), Vector2i(20, 20)]:
		_px(img, corner.x, corner.y, GOLD_HI)
		_px(img, corner.x + (1 if corner.x < 12 else -1), corner.y, GOLD)
		_px(img, corner.x, corner.y + (1 if corner.y < 12 else -1), GOLD)
		_px(img, corner.x + (1 if corner.x < 12 else -1), corner.y + (1 if corner.y < 12 else -1), GOLD_MID)
	return img


## 20×20, 9-Slice mit Rand 6: Runentafel mit Goldkante. gedrückt/gewählt: violett glühend
func _button(pressed: bool) -> Image:
	var layers: Array
	var fill: Color
	if pressed:
		layers = [
			[OUTLINE, OUTLINE],
			[VIOLET_HI, VIOLET_DARK],
			[Color("#2a1b5c"), Color("#2a1b5c")],
			[VIOLET, Color("#3a2480")],
		]
		fill = Color("#452e8f")
	else:
		layers = [
			[OUTLINE, OUTLINE],
			[GOLD, GOLD_DARK],
			[STONE_DEEP, STONE_DEEP],
			[STONE_HI, STONE_DEEP],
		]
		fill = STONE
	var img := _frame(20, 20, 3, layers, fill)
	# Kleine Gold- bzw. Glühpunkte in den Ecken
	var dot := VIOLET_HI if pressed else GOLD_MID
	for corner in [Vector2i(3, 3), Vector2i(16, 3), Vector2i(3, 16), Vector2i(16, 16)]:
		_px(img, corner.x, corner.y, dot)
	return img


## 12×8, 9-Slice mit Rand 3: eingelassene Rille im Stein
func _slider_track() -> Image:
	var layers := [
		[OUTLINE, OUTLINE],
		[STONE_DEEP, STONE_LIGHT],
		[Color("#0f0b18"), Color("#0f0b18")],
	]
	return _frame(12, 8, 2, layers, Color("#0f0b18"))


## 16×16: goldgefasster violetter Runenstein (Raute)
func _slider_grabber() -> Image:
	var img := _new(16, 16)
	for y in 16:
		for x in 16:
			var m := absf(x - 7.5) + absf(y - 7.5)
			if m > 8.0:
				continue
			if m > 7.0:
				img.set_pixel(x, y, OUTLINE)
			elif m > 5.0:
				img.set_pixel(x, y, GOLD if (x + y) < 15 else GOLD_DARK)
			else:
				img.set_pixel(x, y, VIOLET if (x + y) < 15 else VIOLET_DARK)
	_px(img, 6, 6, VIOLET_HI)
	_px(img, 7, 5, VIOLET_HI)
	_px(img, 5, 7, VIOLET_HI)
	return img


## 16×16: Steinplatte mit Goldrand und goldenem Symbol (Pause-Balken bzw. „D“ für Debug)
func _icon_button(kind: String) -> Image:
	var layers := [
		[OUTLINE, OUTLINE],
		[GOLD, GOLD_DARK],
		[STONE_DEEP, STONE_DEEP],
		[STONE_LIGHT, STONE_DEEP],
	]
	var img := _frame(16, 16, 3, layers, STONE)
	if kind == "pause":
		for bar_x in [5, 9]:
			for y in range(4, 12):
				_px(img, bar_x, y, GOLD_HI)
				_px(img, bar_x + 1, y, GOLD if y < 11 else GOLD_MID)
	else:
		var d := [
			"XXXX.",
			"X...X",
			"X...X",
			"X...X",
			"X...X",
			"X...X",
			"XXXX.",
		]
		for row in d.size():
			for col in 5:
				if d[row][col] == "X":
					_px(img, 5 + col, 4 + row, GOLD_HI if col == 0 else GOLD)
	return img


## 96×9: Trennlinie mit Raute in der Mitte, läuft zu den Seiten aus
func _divider() -> Image:
	var w := 96
	var img := _new(w, 9)
	for x in w:
		var t := absf(x - (w - 1) / 2.0) / (w / 2.0)
		var a := clampf(1.0 - pow(t, 1.6), 0.0, 1.0)
		if a > 0.12:
			_px(img, x, 4, Color(GOLD.r, GOLD.g, GOLD.b, a))
		if a > 0.3:
			_px(img, x, 5, Color(GOLD_DARK.r, GOLD_DARK.g, GOLD_DARK.b, a))
	var c := w / 2
	for y in 9:
		for x in range(c - 5, c + 5):
			var m := absf(x - (c - 0.5)) + absf(y - 4.0)
			if m <= 4.5:
				_px(img, x, y, OUTLINE if m > 3.5 else (GOLD if y < 5 else GOLD_MID))
	_px(img, c - 1, 3, GOLD_HI)
	for off in [-14, 13]:
		_px(img, c + off, 4, GOLD_HI)
		_px(img, c + off, 3, GOLD_MID)
		_px(img, c + off, 5, GOLD_MID)
	return img


# ---------- Hauptmenü-Bild ----------
## 600×270 (= 20:9, im Spiel genau 4× vergrößert): Nacht über einem Schlachtfeld, auf dem die Waffen
## zu Staub zerfallen. Über dem Mond liegt das Siegel des Hohen Zirkels (der Bann).

const BG_W := 600
const BG_H := 270
const MOON := Vector2(468, 74)
const HORIZON := 196
## Fußpunkt des Helden im Bild
const HERO_FEET := Vector2i(104, 240)


func _menu_background() -> Image:
	var img := _new(BG_W, BG_H)
	_bg_sky(img)
	_bg_stars(img)
	_bg_seal(img)
	_bg_moon(img)
	_bg_ridge(img, 150.0, 14.0, Color("#1b1233"), 1)
	_bg_forest(img, 176.0, Color("#120b24"), 11, 24, 2)
	_bg_ridge(img, 190.0, 6.0, Color("#0e0819"), 3)
	_bg_forest(img, 198.0, Color("#0a0614"), 8, 30, 4)
	_bg_ground(img)
	_bg_weapons(img)
	_bg_dust(img)
	return img


func _bayer(x: int, y: int) -> float:
	var m := [[0.0, 0.5], [0.75, 0.25]]
	return m[y % 2][x % 2]


func _bg_sky(img: Image) -> void:
	var stops := [Color("#05030c"), Color("#0b0618"), Color("#150c2b"), Color("#22143f"), Color("#34205a")]
	for y in BG_H:
		var t := clampf(y / float(HORIZON), 0.0, 1.0) * (stops.size() - 1)
		var i := mini(int(t), stops.size() - 2)
		var f := t - i
		for x in BG_W:
			# Zwei Farbstufen, dazwischen Raster-Muster statt weicher Übergang (Pixel-Art-Look)
			img.set_pixel(x, y, stops[i + 1] if f > _bayer(x, y) * 0.9 + 0.05 else stops[i])


func _bg_stars(img: Image) -> void:
	for n in 150:
		var x := rng.randi_range(0, BG_W - 1)
		var y := int(pow(rng.randf(), 1.6) * 150.0)
		var c := Color("#c9c0e8") if rng.randf() < 0.7 else Color("#8f84c4")
		img.set_pixel(x, y, c)
		if rng.randf() < 0.07:
			_px(img, x - 1, y, c.darkened(0.45))
			_px(img, x + 1, y, c.darkened(0.45))
			_px(img, x, y - 1, c.darkened(0.45))
			_px(img, x, y + 1, c.darkened(0.45))


## Das Siegel des Hohen Zirkels: zwei gestrichelte Ringe mit Runenstrichen um den Mond
func _bg_seal(img: Image) -> void:
	for radius: float in [58.0, 50.0]:
		var steps := int(TAU * radius * 1.6)
		for i in steps:
			if (i / 3) % 2 == 0:
				continue
			var a := i * TAU / steps
			var p := MOON + Vector2.from_angle(a) * radius
			_blend(img, roundi(p.x), roundi(p.y), Color(VIOLET.r, VIOLET.g, VIOLET.b, 0.55))
	# Zwölf Runenstriche zwischen den Ringen
	for k in 12:
		var a := k * TAU / 12.0 + 0.13
		var dir := Vector2.from_angle(a)
		for s in range(0, 5):
			var p := MOON + dir * (51.0 + s * 1.6)
			var glow := Color(GOLD.r, GOLD.g, GOLD.b, 0.8 if s % 2 == 0 else 0.5)
			_blend(img, roundi(p.x), roundi(p.y), glow)
		# Querstrich als „Rune“
		var side := dir.orthogonal()
		var mid := MOON + dir * 54.0
		_blend(img, roundi(mid.x + side.x * 1.5), roundi(mid.y + side.y * 1.5), Color(GOLD.r, GOLD.g, GOLD.b, 0.7))
		_blend(img, roundi(mid.x - side.x * 1.5), roundi(mid.y - side.y * 1.5), Color(GOLD.r, GOLD.g, GOLD.b, 0.7))
	# Schwacher Schein um den Mond (stufig)
	for y in range(int(MOON.y) - 70, int(MOON.y) + 70):
		for x in range(int(MOON.x) - 70, int(MOON.x) + 70):
			var d := Vector2(x, y).distance_to(MOON)
			if d > 26.0 and d < 68.0:
				var a := (1.0 - (d - 26.0) / 42.0) * 0.22
				if a > _bayer(x, y) * 0.12:
					_blend(img, x, y, Color(0.55, 0.45, 0.85, 0.16))


func _bg_moon(img: Image) -> void:
	for y in range(int(MOON.y) - 24, int(MOON.y) + 25):
		for x in range(int(MOON.x) - 24, int(MOON.x) + 25):
			var d := Vector2(x + 0.5, y + 0.5).distance_to(MOON)
			if d > 22.0:
				continue
			var c := Color("#efe6c4")
			if (x + y) % 7 == 0 and d > 16.0:
				c = Color("#d9cfa8")
			if d > 20.0:
				c = Color("#cfc59c")
			img.set_pixel(x, y, c)
	# Krater
	for crater in [[-8, -6, 5], [7, 5, 4], [-2, 11, 3], [10, -9, 2], [-13, 5, 2]]:
		var cp: Vector2 = MOON + Vector2(crater[0], crater[1])
		for y in range(int(cp.y) - crater[2], int(cp.y) + crater[2] + 1):
			for x in range(int(cp.x) - crater[2], int(cp.x) + crater[2] + 1):
				var d := Vector2(x + 0.5, y + 0.5).distance_to(cp)
				if d <= crater[2] and Vector2(x + 0.5, y + 0.5).distance_to(MOON) < 21.0:
					img.set_pixel(x, y, Color("#bdb28a") if d > crater[2] - 1.2 else Color("#cbbf97"))


## Bergrücken-Silhouette aus periodischem Rauschen
func _bg_ridge(img: Image, base: float, amplitude: float, color: Color, seed_value: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 300 + seed_value
	var knots := PackedFloat32Array()
	for i in 40:
		knots.append(r.randf())
	for x in BG_W:
		var f := x / 14.0
		var i := int(f)
		var t := smoothstep(0.0, 1.0, f - i)
		var h := lerpf(knots[i % 40], knots[(i + 1) % 40], t)
		var f2 := x / 5.0
		var i2 := int(f2)
		var h2 := lerpf(knots[(i2 * 3) % 40], knots[(i2 * 3 + 3) % 40], smoothstep(0.0, 1.0, f2 - i2))
		var top := int(base - (h * 0.75 + h2 * 0.25) * amplitude)
		for y in range(top, BG_H):
			img.set_pixel(x, y, color)


func _bg_forest(img: Image, base: float, color: Color, min_h: int, max_h: int, seed_value: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 500 + seed_value
	var x := -4
	while x < BG_W + 4:
		var h := r.randi_range(min_h, max_h)
		_pine(img, x, int(base), h, color)
		x += r.randi_range(3, 9)
	for y in range(int(base), BG_H):
		for xx in BG_W:
			img.set_pixel(xx, y, color)


func _pine(img: Image, cx: int, base_y: int, h: int, color: Color) -> void:
	for row in h:
		var t := row / float(h)
		var half := int(1.0 + t * h * 0.28)
		for x in range(cx - half, cx + half + 1):
			_px(img, x, base_y - h + row, color)
	for y in range(base_y - 2, base_y + 1):
		_px(img, cx, y, color)


## Obere Kante des Vordergrunds in Spalte x
func _ground_top(x: int) -> int:
	return int(HORIZON + 9 + sin(x * 0.021) * 3.0 + sin(x * 0.07 + 1.0) * 1.6)


## Vordergrund: Wiese im Mondlicht, nach unten immer dunkler (mit Raster-Übergang wie der Himmel)
func _bg_ground(img: Image) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 700
	var stops := [Color("#25392c"), Color("#182822"), Color("#111c1d"), Color("#0d1018"), Color("#08060f")]
	for x in BG_W:
		var top := _ground_top(x)
		for y in range(top, BG_H):
			var t := clampf((y - top) / float(BG_H - top), 0.0, 1.0) * (stops.size() - 1)
			var i := mini(int(t), stops.size() - 2)
			var f := t - i
			var c: Color = stops[i + 1] if f > _bayer(x, y) * 0.9 + 0.05 else stops[i]
			if y == top:
				c = Color("#3d5a42")
			elif y == top + 1:
				c = Color("#2c4532")
			elif y < top + 30 and r.randf() < 0.05:
				c = Color("#34503a")
			img.set_pixel(x, y, c)
		# Grashalme über der Kante
		if r.randf() < 0.45:
			_px(img, x, top - 1, Color("#3d5a42"))
			if r.randf() < 0.4:
				_px(img, x, top - 2, Color("#2c4532"))


## Schwert, mit der Spitze im Boden. width: 1–3 Pixel breite Klinge.
## state 0: ganz, 1: Parierstange und Griff zerfallen schon, 2: abgebrochene Klinge
func _sword(img: Image, tip: Vector2, blade_len: int, tilt: float, width: int, haze: float, state: int) -> void:
	var dir := Vector2(sin(tilt), -cos(tilt))
	var side := dir.orthogonal()
	var fog := Color("#1a1430")
	var steel := Color("#9aa0bd").lerp(fog, haze)
	var steel_hi := Color("#e2e6f8").lerp(fog, haze)
	var steel_dark := Color("#5f6482").lerp(fog, haze)
	var gold := GOLD.lerp(fog, haze)
	var gold_dark := GOLD_MID.lerp(fog, haze)
	var grip := Color("#5a3a22").lerp(fog, haze)
	var length := blade_len if state != 2 else int(blade_len * 0.6)
	for i in length:
		var p := tip + dir * i
		# Die Spitze läuft schmal zu
		var w := 1 if i < 3 else width
		for k in w:
			var o := k - (w - 1) / 2.0
			var c := steel
			if w == 1:
				c = steel_hi
			elif k == 0:
				c = steel_hi
			elif k == w - 1:
				c = steel_dark
			_px(img, roundi(p.x + side.x * o), roundi(p.y + side.y * o), c)
	if state == 2:
		# Zackige Bruchkante
		var p := tip + dir * length
		_px(img, roundi(p.x + side.x * 0.5), roundi(p.y + side.y * 0.5), steel_hi)
		_px(img, roundi(p.x - side.x), roundi(p.y - side.y), steel_dark)
		return
	var guard_c := tip + dir * blade_len
	var guard_half := 2 + width
	var guard_cells := range(-guard_half, guard_half + 1)
	if state == 1:
		guard_cells = [-guard_half, guard_half] if rng.randf() < 0.5 else [-guard_half, -guard_half + 1]
	for k: int in guard_cells:
		_px(img, roundi(guard_c.x + side.x * k), roundi(guard_c.y + side.y * k), gold if absi(k) < guard_half else gold_dark)
	if state == 0:
		var grip_len := 2 + width
		for i in range(1, grip_len):
			var p := guard_c + dir * i
			_px(img, roundi(p.x), roundi(p.y), grip)
		var pommel := guard_c + dir * grip_len
		_px(img, roundi(pommel.x), roundi(pommel.y), gold)
		_px(img, roundi(pommel.x + side.x), roundi(pommel.y + side.y), gold_dark)


func _spear(img: Image, tip: Vector2, length: int, tilt: float, haze: float) -> void:
	var dir := Vector2(sin(tilt), -cos(tilt))
	var side := dir.orthogonal()
	var fog := Color("#1a1430")
	var wood := Color("#6a4528").lerp(fog, haze)
	var steel := Color("#c4c9e2").lerp(fog, haze)
	for i in length:
		var p := tip + dir * i
		_px(img, roundi(p.x), roundi(p.y), steel if i < 5 else wood)
		if i >= 1 and i <= 3:
			_px(img, roundi(p.x + side.x), roundi(p.y + side.y), steel.darkened(0.25))
	# Zerfaserndes Ende
	var end := tip + dir * length
	_px(img, roundi(end.x + side.x), roundi(end.y + side.y), wood.darkened(0.3))


func _bow(img: Image, base: Vector2, size: int, haze: float) -> void:
	var fog := Color("#1a1430")
	var wood := Color("#7a5230").lerp(fog, haze)
	var string := Color("#b8ad90").lerp(fog, haze)
	for i in size:
		var t := i / float(size - 1)
		var bulge := sin(t * PI) * size * 0.3
		_px(img, roundi(base.x + bulge), roundi(base.y - i), wood)
		_px(img, roundi(base.x + bulge + 1.0), roundi(base.y - i), wood.darkened(0.35))
		if i % 2 == 0 and i > 0 and i < size - 1:
			_px(img, roundi(base.x), roundi(base.y - i), string)


## Zerfallende Waffen im Boden, links und rechts im Bild (die Mitte bleibt frei für das Menü).
## Der Held steht zwischen ihnen und wird in der richtigen Tiefe eingefügt.
func _bg_weapons(img: Image) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 900
	var items := []
	for n in 36:
		var side_left := r.randf() < 0.5
		var x := r.randf_range(6.0, 200.0) if side_left else r.randf_range(390.0, 594.0)
		# Nähe: 0 = weit hinten (klein, dunstig), 1 = ganz vorn (groß)
		var near := pow(r.randf(), 0.75)
		var y := HORIZON + 18.0 + near * 50.0
		var kind := r.randf()
		if absf(x - HERO_FEET.x) < 22.0 and y > HERO_FEET.y - 30.0:
			continue
		items.append([x, y, near, kind])
	items.sort_custom(func(a: Array, b: Array) -> bool: return a[1] < b[1])
	var hero_done := false
	for it: Array in items:
		if not hero_done and it[1] > HERO_FEET.y:
			_bg_hero(img)
			hero_done = true
		var near: float = it[2]
		var tip := Vector2(it[0], it[1])
		var tilt := r.randf_range(-0.3, 0.3)
		var haze := (1.0 - near) * 0.5
		var kind: float = it[3]
		var length := int(lerpf(12.0, 38.0, near))
		var width := 1 if near < 0.35 else (2 if near < 0.75 else 3)
		if kind < 0.6:
			var state := 0 if r.randf() < 0.45 else (1 if r.randf() < 0.6 else 2)
			_sword(img, tip, length, tilt, width, haze, state)
		elif kind < 0.82:
			_spear(img, tip, int(length * 1.4), tilt, haze)
		else:
			_bow(img, tip, int(length * 0.9), haze)
		# Staub steigt aus jeder Waffe auf: Die Waffen zerfallen
		var top := tip + Vector2(sin(tilt), -cos(tilt)) * length
		for k in int(5 + near * 9):
			var q := top + Vector2(r.randf_range(-5.0, 5.0), -r.randf_range(1.0, 24.0 + near * 18.0))
			var fade := clampf(1.0 - (top.y - q.y) / 44.0, 0.2, 1.0)
			var c := Color(VIOLET_HI.r, VIOLET_HI.g, VIOLET_HI.b, 0.8 * fade) if r.randf() < 0.65 else Color(GOLD_HI.r, GOLD_HI.g, GOLD_HI.b, 0.75 * fade)
			_blend(img, roundi(q.x), roundi(q.y), c)
			if near > 0.6 and r.randf() < 0.2:
				_blend(img, roundi(q.x) + 1, roundi(q.y), c)
	if not hero_done:
		_bg_hero(img)


## Der Held steht zwischen den Waffen, die um ihn herum zerfallen: Schimmer in der Luft und Schatten am Boden
func _bg_hero(img: Image) -> void:
	var hero := Image.load_from_file(HERO)
	hero.convert(Image.FORMAT_RGBA8)
	var frame := hero.get_region(Rect2i(0, 0, 32, 32))
	var feet := HERO_FEET
	var center := Vector2(feet.x, feet.y - 14.0)
	for y in range(int(center.y) - 34, int(center.y) + 34):
		for x in range(int(center.x) - 34, int(center.x) + 34):
			var d := Vector2(x, y).distance_to(center)
			if d < 32.0 and (1.0 - d / 32.0) * 0.5 > _bayer(x, y) * 0.28:
				_blend(img, x, y, Color(VIOLET.r, VIOLET.g, VIOLET.b, 0.2))
	for y in range(feet.y - 2, feet.y + 3):
		for x in range(feet.x - 11, feet.x + 12):
			var e := pow((x - feet.x) / 11.0, 2.0) + pow((y - feet.y) / 2.5, 2.0)
			if e <= 1.0:
				_blend(img, x, y, Color(0.02, 0.01, 0.05, 0.6))
	for y in 32:
		for x in 32:
			var c := frame.get_pixel(x, y)
			if c.a < 0.5:
				continue
			_px(img, feet.x - 16 + x, feet.y - 31 + y, Color(c.r, c.g, c.b, 1.0))


func _bg_dust(img: Image) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 1100
	for n in 220:
		var x := r.randi_range(0, BG_W - 1)
		var y := r.randi_range(70, BG_H - 10)
		var a := r.randf_range(0.3, 0.8)
		var c := Color(VIOLET_HI.r, VIOLET_HI.g, VIOLET_HI.b, a) if r.randf() < 0.7 else Color(GOLD_HI.r, GOLD_HI.g, GOLD_HI.b, a)
		_blend(img, x, y, c)
		if r.randf() < 0.12:
			_blend(img, x + 1, y, Color(c.r, c.g, c.b, c.a * 0.6))
			_blend(img, x, y - 1, Color(c.r, c.g, c.b, c.a * 0.6))
