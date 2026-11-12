extends SceneTree
## Erzeugt die Waffen-Icons (32×32, zeigen die Waffe selbst) nach assets/sprites/icons/weapon_<id>.png.
## Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_weapon_icons.gd
## Farben aus der gemeinsamen Palette (tools/palette.gd), dunkler Rand, Licht von oben links.
const SIZE := 32
const OUT := "res://assets/sprites/icons/"

var OUTLINE := Palette.snap(Color("#0c0d0f"))
var WOOD_LIGHT := Palette.snap(Color("#8a6e52"))
var WOOD := Palette.snap(Color("#514043"))
var WOOD_DARK := Palette.snap(Color("#332930"))
var GOLD_LIGHT := Palette.snap(Color("#f9c769"))
var GOLD := Palette.snap(Color("#cb8038"))
var GOLD_DARK := Palette.snap(Color("#a45b30"))
var ORB_DARK := Palette.snap(Color("#376281"))
var ORB := Palette.snap(Color("#62b8da"))
var ORB_LIGHT := Palette.snap(Color("#cdfcfa"))
var WHITE := Palette.snap(Color("#f4f6f0"))


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	_arcane_wand().save_png(OUT + "weapon_arcane_wand.png")
	print("ok")
	quit()


func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < SIZE and y < SIZE:
		img.set_pixel(x, y, c)


## Dunklen 1-px-Rand um alles Gezeichnete (auch diagonal, damit die Form geschlossen wirkt)
func _outline(img: Image) -> void:
	var edge: Array[Vector2i] = []
	for y in SIZE:
		for x in SIZE:
			if img.get_pixel(x, y).a > 0.0:
				continue
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var nx := x + dx
					var ny := y + dy
					if nx >= 0 and ny >= 0 and nx < SIZE and ny < SIZE and img.get_pixel(nx, ny).a > 0.0:
						edge.append(Vector2i(x, y))
	for e in edge:
		img.set_pixel(e.x, e.y, OUTLINE)


## Zauberstab: dunkler Ebenholzschaft mit Goldwicklungen und einem goldenen Mondsichel-Kopf, der eine leuchtende Kugel hält.
## Die Sichel ist ein großer Kreis A ohne einen nach oben rechts verschobenen Kreis B. Die Kugel sitzt im Ausschnitt.
## Der Schaft läuft diagonal vom unteren linken Rand bis zur dicken Seite der Sichel. Licht kommt von oben links.
func _arcane_wand() -> Image:
	var img := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var light := Vector2(-1.0, -1.0).normalized()
	var circle_a := Vector3(22.5, 9.5, 7.2)
	var circle_b := Vector3(25.0, 7.0, 7.9)
	var orb := Vector3(23.4, 8.6, 5.0)
	# Schaft zuerst, der Kopf überdeckt sein oberes Ende
	for k in range(0, 12):
		var x := 15 - k
		var y := 15 + k
		var wrap := k == 3 or k == 4 or k == 9 or k == 10
		_px(img, x, y, GOLD_LIGHT if wrap else WOOD_LIGHT)
		_px(img, x + 1, y, GOLD if wrap else WOOD)
		_px(img, x, y + 1, GOLD_DARK if wrap else WOOD_DARK)
		_px(img, x + 1, y + 1, GOLD_DARK if wrap else WOOD_DARK)
		_px(img, x + 2, y + 1, GOLD_DARK if wrap else WOOD_DARK)
	# Leuchtende Runen auf dem Schaft (zwei Punkte zwischen den Wicklungen)
	for k in [5, 7]:
		_px(img, 16 - k, 15 + k, ORB_LIGHT)
	# Knauf: goldene Kugel am Ende
	for y in range(23, 32):
		for x in range(0, 9):
			var pc := Vector2(x + 0.5, y + 0.5)
			if pc.distance_to(Vector2(4.6, 27.4)) <= 2.7:
				var ps := ((pc - Vector2(4.6, 27.4)) / 2.7).dot(light)
				_px(img, x, y, GOLD_LIGHT if ps > 0.4 else GOLD_DARK if ps < -0.3 else GOLD)
	for y in SIZE:
		for x in SIZE:
			var c := Vector2(x + 0.5, y + 0.5)
			var da := c.distance_to(Vector2(circle_a.x, circle_a.y))
			var db := c.distance_to(Vector2(circle_b.x, circle_b.y))
			if da <= circle_a.z and db > circle_b.z:
				# Schattierung nach der Richtung von der Sichelmitte weg: oben links hell, unten rechts dunkel
				var normal := (c - Vector2(circle_a.x, circle_a.y)).normalized()
				var shade := normal.dot(light)
				var rim := circle_a.z - da  # Abstand vom äußeren Rand
				var color := GOLD
				if shade > 0.45 and rim < 2.5:
					color = GOLD_LIGHT
				elif shade < -0.35:
					color = GOLD_DARK
				# Innenkante der Sichel (am Kreis B) liegt im Schatten der Kugel
				if db - circle_b.z < 1.2 and shade < 0.3:
					color = GOLD_DARK
				_px(img, x, y, color)
	for y in SIZE:
		for x in SIZE:
			var c := Vector2(x + 0.5, y + 0.5)
			var d := c.distance_to(Vector2(orb.x, orb.y))
			if d > orb.z:
				continue
			var shade := ((c - Vector2(orb.x, orb.y)) / orb.z).dot(light)
			var color := ORB
			if shade > 0.3 or d < 1.2:
				color = ORB_LIGHT
			elif shade < -0.4:
				color = ORB_DARK
			_px(img, x, y, color)
	# Glanzpunkte auf der Kugel
	for p in [Vector2i(20, 5), Vector2i(21, 5), Vector2i(20, 6)]:
		_px(img, p.x, p.y, WHITE)
	# Funkeln: ein kleiner Stern oben rechts
	for p in [Vector2i(29, 2), Vector2i(28, 3), Vector2i(30, 3), Vector2i(29, 4), Vector2i(29, 3)]:
		_px(img, p.x, p.y, WHITE if p == Vector2i(29, 3) else ORB_LIGHT)
	_outline(img)
	return _centered(img)


## Schiebt das Bild so, dass das Gezeichnete in der Mitte des 32×32-Feldes liegt
func _centered(img: Image) -> Image:
	var box := Rect2i()
	var found := false
	for y in SIZE:
		for x in SIZE:
			if img.get_pixel(x, y).a > 0.0:
				box = Rect2i(x, y, 1, 1) if not found else box.expand(Vector2i(x, y)).expand(Vector2i(x + 1, y + 1))
				found = true
	var shift := Vector2i(SIZE / 2, SIZE / 2) - (box.position + box.size / 2)
	var out := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	out.blit_rect(img, Rect2i(0, 0, SIZE, SIZE), shift)
	return out
