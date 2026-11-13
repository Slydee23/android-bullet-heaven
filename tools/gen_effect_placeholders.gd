extends SceneTree
## Erzeugt die Platzhalter für Treffer-Funken (hit.png, 4 Frames) und Tod-Staub (death.png, 6 Frames), je 32×32 pro Frame,
## und die kleine Flamme des Feuerrings der Flammenfackel (aura_flame.png, 16×16, 4 Frames).
## Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_effect_placeholders.gd
## Die Farben kommen aus der gemeinsamen Palette der Spielwelt (tools/palette.gd). Beide Dateien lassen sich jederzeit
## durch Alpha-Assets überschreiben (gleicher Name, beliebig viele 32×32-Frames).
const FRAME := 32
const OUT := "res://assets/sprites/effects/"
const HIT_FRAMES := 4
const DEATH_FRAMES := 6
const FLAME_FRAME := 16
const FLAME_FRAMES := 4

var WHITE := Palette.snap(Color("#f4f6f0"))
var CYAN_LIGHT := Palette.snap(Color("#cdfcfa"))
var CYAN := Palette.snap(Color("#8ecbdc"))
var GOLD := Palette.snap(Color("#f9c769"))
var OUTLINE := Palette.snap(Color("#542a4d"))
var BONE_LIGHT := Palette.snap(Color("#ebe8d4"))
var BONE := Palette.snap(Color("#ddd4b5"))
var BONE_DARK := Palette.snap(Color("#cdbf9b"))
var DUST := Palette.snap(Color("#9a8163"))
var FIRE_YELLOW := Palette.snap(Color("#f9c769"))
var FIRE_ORANGE := Palette.snap(Color("#cb8038"))
var FIRE_RED := Palette.snap(Color("#c45836"))


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	_make_hit().save_png(OUT + "hit.png")
	_make_death().save_png(OUT + "death.png")
	_make_aura_flame().save_png(OUT + "aura_flame.png")
	print("ok")
	quit()


func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)


## Funken: ein Stern, der aufblitzt, sich zum Ring weitet und in einzelne Funken zerfällt
func _make_hit() -> Image:
	var sheet := Image.create_empty(FRAME * HIT_FRAMES, FRAME, false, Image.FORMAT_RGBA8)
	var center := Vector2(15.5, 15.5)
	var rng := RandomNumberGenerator.new()
	for f in HIT_FRAMES:
		rng.seed = 100 + f
		var ox := f * FRAME
		var length: float = [6.0, 9.0, 12.0, 14.0][f]
		var rays := 8
		for k in rays:
			var angle := TAU * k / rays + 0.2
			# Lange Strahlen zeigen in die Achsen, die dazwischen sind kürzer
			var ray_length := length if k % 2 == 0 else length * 0.6
			var from := 0.0 if f < 2 else ray_length * 0.45
			var steps := int(ray_length)
			for s in range(int(from), steps + 1):
				if f >= 2 and rng.randf() < 0.25 * (f - 1):
					continue
				var p := center + Vector2.from_angle(angle) * s
				var c := CYAN
				if s < ray_length * 0.4:
					c = WHITE
				elif s > ray_length * 0.8:
					c = GOLD
				_px(sheet, ox + roundi(p.x), roundi(p.y), c)
		if f < 2:
			var core := 2 - f
			for y in range(-core, core + 1):
				for x in range(-core, core + 1):
					if absi(x) + absi(y) <= core:
						_px(sheet, ox + 15 + x, 15 + y, WHITE)
		_outline(sheet, ox)
	return sheet


## Dunkler 1-px-Rand um alle Funkenpixel eines Frames, damit sie sich vom Waldboden abheben
func _outline(img: Image, ox: int, frame := FRAME) -> void:
	var edge: Array[Vector2i] = []
	for y in frame:
		for x in frame:
			if img.get_pixel(ox + x, y).a > 0.0:
				continue
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < frame and ny < frame and img.get_pixel(ox + nx, ny).a > 0.0:
					edge.append(Vector2i(x, y))
					break
	for e in edge:
		img.set_pixel(ox + e.x, e.y, OUTLINE)


## Staub: Eine Wolke aus Knochenstaub steigt auf und löst sich auf, dazu fliegen ein paar Knochensplitter heraus
func _make_death() -> Image:
	var sheet := Image.create_empty(FRAME * DEATH_FRAMES, FRAME, false, Image.FORMAT_RGBA8)
	var colors := [BONE_LIGHT, BONE, BONE_DARK, DUST]
	var blobs := []
	var seed_rng := RandomNumberGenerator.new()
	seed_rng.seed = 7
	for k in 7:
		blobs.append([seed_rng.randf_range(-7.0, 7.0), seed_rng.randf_range(-4.0, 1.0), seed_rng.randf_range(2.5, 5.0), seed_rng.randf_range(0.0, 1.0)])
	var shards := []
	for k in 5:
		shards.append([seed_rng.randf_range(-1.0, 1.0), seed_rng.randf_range(-2.2, -0.8)])
	for f in DEATH_FRAMES:
		var rng := RandomNumberGenerator.new()
		rng.seed = 200 + f
		var ox := f * FRAME
		var t := f / float(DEATH_FRAMES - 1)
		# Die Wolke liegt am Boden (Fußpunkt unten in der Mitte) und steigt auf
		for blob: Array in blobs:
			var radius: float = blob[2] * (0.6 + t * 0.9)
			var cx: float = 15.5 + blob[0] * (0.6 + t * 0.9)
			var cy: float = 26.0 + blob[1] - t * (10.0 + blob[3] * 6.0)
			for y in range(int(cy - radius) - 1, int(cy + radius) + 2):
				for x in range(int(cx - radius) - 1, int(cx + radius) + 2):
					var d := Vector2(x + 0.5, y + 0.5).distance_to(Vector2(cx, cy))
					if d > radius:
						continue
					# Zum Ende löst sich die Wolke Pixel für Pixel auf
					if rng.randf() < t * t * 1.1:
						continue
					var shade := 0
					if d > radius * 0.7:
						shade = 2
					elif d < radius * 0.35:
						shade = 0
					else:
						shade = 1
					if y > cy + radius * 0.3:
						shade = mini(shade + 1, 3)
					_px(sheet, ox + x, y, colors[shade])
		# Knochensplitter
		if f >= 1 and f <= 4:
			for shard: Array in shards:
				var sx: float = 15.5 + shard[0] * 9.0 * f
				var sy: float = 22.0 + shard[1] * 5.0 * f + 1.6 * f * f
				_px(sheet, ox + roundi(sx), roundi(sy), WHITE)
				_px(sheet, ox + roundi(sx) + 1, roundi(sy), BONE)
	return sheet


## Kleine Flamme für den Feuerring: Der Bildinhalt liegt vertikal mittig im Frame (Zeilen 2–13 von 16), denn der Ring legt die
## Bildmitte auf die Ringlinie (die Flamme steht halb innerhalb, halb außerhalb des Trefferradius). Flackert über 4 Frames
## (Höhe und Neigung der Spitze wechseln). Außen rot, dann orange, innen gelb, dunkler Rand wie bei den Funken.
func _make_aura_flame() -> Image:
	var sheet := Image.create_empty(FLAME_FRAME * FLAME_FRAMES, FLAME_FRAME, false, Image.FORMAT_RGBA8)
	# Pro Frame: Höhe der Hauptzunge, ihre Neigung, Seite (−1/+1) und Höhe der kleinen Nebenzunge
	var heights: Array[float] = [7.0, 8.0, 7.5, 8.5]
	var leans: Array[float] = [0.05, 0.15, -0.1, 0.0]
	var sides: Array[float] = [1.0, -1.0, 1.0, -1.0]
	var side_heights: Array[float] = [4.5, 3.5, 5.0, 4.0]
	for f in FLAME_FRAMES:
		var ox := f * FLAME_FRAME
		var tongues := [
			[Vector2(8.0, 10.0), 3.8, heights[f], leans[f]],
			[Vector2(8.0 + sides[f] * 2.3, 10.5), 2.3, side_heights[f], sides[f] * 0.15],
		]
		_flame_layer(sheet, ox, tongues, 1.0, FIRE_RED)
		_flame_layer(sheet, ox, tongues, 0.68, FIRE_ORANGE)
		_flame_layer(sheet, ox, tongues, 0.38, FIRE_YELLOW)
		_outline(sheet, ox, FLAME_FRAME)
	return sheet


## Eine Farbschicht der Flamme aus mehreren Zungen [Mitte, Radius, Höhe der Spitze, Neigung]: unten ein runder Bauch,
## darüber eine Spitze. scale verkleinert alle Zungen zum Kern hin (der Boden bleibt, die Mitte rückt leicht nach unten).
func _flame_layer(img: Image, ox: int, tongues: Array, scale: float, color: Color) -> void:
	for y in FLAME_FRAME:
		for x in FLAME_FRAME:
			var p := Vector2(x + 0.5, y + 0.5)
			if p.y > 13.0:
				continue
			for tongue: Array in tongues:
				var r: float = tongue[1] * scale
				var height: float = tongue[2] * scale
				var center: Vector2 = tongue[0] + Vector2(0.0, (1.0 - scale) * 2.0)
				var inside := p.distance_to(center) <= r
				if not inside and p.y < center.y:
					var up := center.y - p.y
					if up <= height:
						inside = absf(p.x - (center.x + up * float(tongue[3]))) <= r * (1.0 - up / height)
				if inside:
					_px(img, ox + x, y, color)
					break
