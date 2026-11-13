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
# Stahl (kühle, leicht bläuliche Grautöne der Palette)
var STEEL_LIGHT := Palette.snap(Color("#8ecbdc"))
var STEEL := Palette.snap(Color("#6898b2"))
var STEEL_DARK := Palette.snap(Color("#404a66"))
# Leder (Griff) und Stoff (Fackelwicklung)
var LEATHER := Palette.snap(Color("#784030"))
var LEATHER_DARK := Palette.snap(Color("#542a4d"))
var CLOTH_LIGHT := Palette.snap(Color("#7c394d"))
var CLOTH_DARK := Palette.snap(Color("#542a4d"))
# Knochen
var BONE_LIGHT := Palette.snap(Color("#ebe8d4"))
var BONE := Palette.snap(Color("#ddd4b5"))
var BONE_SHADE := Palette.snap(Color("#cdbf9b"))
var BONE_DARK := Palette.snap(Color("#9a8163"))
# Feuer
var FIRE_CORE := Palette.snap(Color("#f4f6f0"))
var FIRE_YELLOW := Palette.snap(Color("#f9c769"))
var FIRE_ORANGE := Palette.snap(Color("#cb8038"))
var FIRE_RED := Palette.snap(Color("#c45836"))
var FIRE_DARK := Palette.snap(Color("#924b35"))


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	_arcane_wand().save_png(OUT + "weapon_arcane_wand.png")
	_orbit_sword().save_png(OUT + "weapon_orbit_sword.png")
	_flame_torch().save_png(OUT + "weapon_flame_torch.png")
	print("ok")
	quit()


## Füllt eine (sich zur Spitze hin verjüngende) Linie von a nach b mit Licht von oben links:
## Pixel auf der dem Licht zugewandten Seite bekommen colors[0], die Mitte colors[1], die Schattenseite colors[2].
## taper = Länge in Pixeln, über die die Breite am Ende b auf 0 ausläuft (0 = keine Spitze).
func _bar(img: Image, a: Vector2, b: Vector2, half_width: float, colors: Array, taper := 0.0) -> void:
	var axis := b - a
	var length := axis.length()
	var dir := axis / length
	var normal := Vector2(-dir.y, dir.x)
	# Die Normale soll zum Licht (oben links) zeigen
	if normal.dot(Vector2(-1, -1)) < 0.0:
		normal = -normal
	for y in SIZE:
		for x in SIZE:
			var p := Vector2(x + 0.5, y + 0.5) - a
			var along := p.dot(dir)
			if along < -0.5 or along > length + 0.5:
				continue
			var width := half_width
			if taper > 0.0 and along > length - taper:
				width = half_width * clampf((length - along) / taper, 0.0, 1.0) + 0.35
			var side := p.dot(normal)
			if absf(side) > width:
				continue
			var color: Color = colors[1]
			if side > width * 0.35:
				color = colors[0]
			elif side < -width * 0.35:
				color = colors[2]
			_px(img, x, y, color)


func _ball(img: Image, center: Vector2, radius: float, light: Color, mid: Color, dark: Color) -> void:
	for y in SIZE:
		for x in SIZE:
			var p := Vector2(x + 0.5, y + 0.5)
			if p.distance_to(center) > radius:
				continue
			var shade := ((p - center) / radius).dot(Vector2(-1, -1).normalized())
			_px(img, x, y, light if shade > 0.35 else dark if shade < -0.35 else mid)


## Kreisendes Schwert: schlichtes Stahl-Kurzschwert, diagonal (Knauf unten links, Spitze oben rechts),
## goldene Parierstange, dunkler Ledergriff, Klinge mit dunkler Hohlkehle in der Mitte.
func _orbit_sword() -> Image:
	var img := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var guard := Vector2(11.5, 20.5)
	var tip := Vector2(28.0, 4.0)
	var dir := (tip - guard).normalized()
	var across := Vector2(-dir.y, dir.x)
	# Griff mit Lederwicklung (heller Streifen alle 2 Pixel)
	_bar(img, guard, guard - dir * 6.5, 1.2, [LEATHER, LEATHER, LEATHER_DARK])
	for k: int in [2, 4]:
		var p := guard - dir * k
		_px(img, int(p.x), int(p.y), LEATHER_DARK)
	_ball(img, guard - dir * 7.6, 1.9, GOLD_LIGHT, GOLD, GOLD_DARK)
	# Klinge
	_bar(img, guard + dir * 1.0, tip, 1.7, [WHITE, STEEL_LIGHT, STEEL], 5.0)
	# Hohlkehle: dunkle Linie in der Klingenmitte
	for k in range(3, 13):
		var p := guard + dir * k
		_px(img, int(p.x), int(p.y), STEEL)
	# Parierstange quer zur Klinge
	_bar(img, guard + across * 4.2, guard - across * 4.2, 1.1, [GOLD_LIGHT, GOLD, GOLD_DARK])
	_outline(img)
	return _centered(img)


## Knochenfackel: langer Knochen als Stiel (Gelenkkopf unten links), oben mit dunkelrotem Stoff umwickelt,
## darüber eine große Flamme, die nach oben (nicht diagonal) brennt.
func _flame_torch() -> Image:
	var img := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var foot := Vector2(6.0, 26.0)
	var head := Vector2(18.5, 13.5)
	var dir := (head - foot).normalized()
	var across := Vector2(-dir.y, dir.x)
	# Gelenkkopf des Knochens: zwei kleine Kugeln nebeneinander
	_ball(img, foot + across * 1.6, 2.0, BONE_LIGHT, BONE, BONE_DARK)
	_ball(img, foot - across * 1.6, 2.0, BONE_LIGHT, BONE, BONE_DARK)
	# Knochenschaft
	_bar(img, foot, head, 1.3, [BONE_LIGHT, BONE, BONE_SHADE])
	# Stoffwicklung am oberen Ende (schräge Streifen)
	_bar(img, head - dir * 5.0, head + dir * 0.5, 2.3, [CLOTH_LIGHT, CLOTH_LIGHT, CLOTH_DARK])
	for k: int in [-4, -2, 0]:
		var p := head + dir * k
		for s: int in [-1, 0, 1]:
			var q := p + across * s - dir * (s * 0.5)
			_px(img, int(q.x), int(q.y), CLOTH_DARK)
	# Flamme: Tropfenform nach oben, außen rot, dann orange, gelb, weißer Kern
	_flame(img, Vector2(21.0, 10.5), 4.8, 9.0, FIRE_RED)
	_flame(img, Vector2(21.2, 11.0), 3.6, 6.5, FIRE_ORANGE)
	_flame(img, Vector2(21.4, 11.5), 2.4, 4.5, FIRE_YELLOW)
	_flame(img, Vector2(21.5, 12.0), 1.2, 2.0, FIRE_CORE)
	# Glut-Funken über der Flamme
	for p in [Vector2i(25, 2), Vector2i(17, 3)]:
		_px(img, p.x, p.y, FIRE_YELLOW)
	_outline(img)
	return _centered(img)


## Tropfenförmige Flamme: unten ein Kreis (Radius r), darüber eine Spitze bis height Pixel über der Kreismitte,
## leicht nach rechts geneigt.
func _flame(img: Image, center: Vector2, r: float, height: float, color: Color) -> void:
	for y in SIZE:
		for x in SIZE:
			var p := Vector2(x + 0.5, y + 0.5)
			var inside := p.distance_to(center) <= r
			if not inside and p.y < center.y:
				var up := center.y - p.y
				if up <= height:
					var half := r * (1.0 - up / height)
					inside = absf(p.x - (center.x + up * 0.18)) <= half
			if inside:
				_px(img, x, y, color)


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
