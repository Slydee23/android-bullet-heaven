extends SceneTree
## Erzeugt die Seelensplitter (XP-Kristalle) als Pixel-Art. Aufruf (im Projektordner):
## Godot --headless --path . -s tools/gen_pickups.gd
## Schreibt assets/sprites/pickups/xp_crystal.png: 3 Zeilen (klein blau, mittel grün, groß violett) × 4 Frames à 16×16.
## Die Füße (Spitze unten) stehen bei y = 14, die Mitte bei x = 7. Ersetzbar durch ein Alpha-Asset mit gleichem Aufbau.

const OUT := "res://assets/sprites/pickups/xp_crystal.png"
const FRAME := 16
const FRAMES := 4
const BOTTOM := 14
const CENTER_X := 7

## Je Stufe: Farben [Umriss, dunkel, mittel, hell, Glanz], Höhe und halbe Breite des Splitters
const TIERS := [
	{"colors": ["#121e33", "#376281", "#62b8da", "#8ecbdc", "#effffe"], "height": 9, "half": 2},
	{"colors": ["#0f2a1a", "#2f7a45", "#4fb35f", "#8fdc7a", "#efffe0"], "height": 11, "half": 3},
	{"colors": ["#1e1035", "#4a2f8c", "#7a5cd0", "#b49cff", "#f6f0ff"], "height": 13, "half": 4},
]


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/sprites/pickups"))
	var sheet := Image.create_empty(FRAME * FRAMES, FRAME * TIERS.size(), false, Image.FORMAT_RGBA8)
	for tier in TIERS.size():
		for frame in FRAMES:
			_draw_shard(sheet, Vector2i(frame * FRAME, tier * FRAME), TIERS[tier], frame)
	sheet.save_png(OUT)
	print("ok")
	quit()


## Halbe Breite einer Zeile: unten spitz, am breitesten bei 40 % der Höhe (von oben), oben wieder spitz
func _half_width(row: int, height: int, half: int) -> int:
	var t := row / float(height - 1)
	var shape := t / 0.4 if t < 0.4 else (1.0 - t) / 0.6
	return int(roundf(half * shape))


func _draw_shard(sheet: Image, origin: Vector2i, tier: Dictionary, frame: int) -> void:
	var c: Array[Color] = []
	for hex in tier["colors"]:
		c.append(Color(hex))
	var height: int = tier["height"]
	var half: int = tier["half"]
	var top := BOTTOM - height + 1
	# Splitter füllen: linke Facette hell, Mittelgrat mit Glanz, rechte Facette dunkler, untere Hälfte jeweils eine Stufe dunkler
	var filled := {}
	for row in height:
		var y := top + row
		var w := _half_width(row, height, half)
		var lower := row > height * 0.5
		for x in range(CENTER_X - w, CENTER_X + w + 1):
			var color: Color
			if x < CENTER_X:
				color = c[2] if lower else c[3]
			elif x == CENTER_X:
				color = c[3] if lower else c[4]
			else:
				color = c[1] if lower else c[2]
			# Frame 1: Glanz wandert über die linke Facette
			if frame == 1 and x == CENTER_X - 1 and not lower:
				color = c[4]
			sheet.set_pixel(origin.x + x, origin.y + y, color)
			filled[Vector2i(x, y)] = true
	# Umriss um alle gefüllten Pixel
	for p in filled.keys():
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = p + d
			if not filled.has(n) and n.x >= 0 and n.y >= 0 and n.x < FRAME and n.y < FRAME:
				sheet.set_pixel(origin.x + n.x, origin.y + n.y, c[0])
	# Funkeln oben rechts: Frame 2 ein Kreuz, Frame 3 ein einzelner Punkt
	var spark := Vector2i(CENTER_X + half + 1, top + 1)
	if frame == 2:
		sheet.set_pixel(origin.x + spark.x, origin.y + spark.y, c[4])
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = spark + d
			if n.x < FRAME and n.y >= 0:
				sheet.set_pixel(origin.x + n.x, origin.y + n.y, Color(c[3], 0.8))
	elif frame == 3:
		sheet.set_pixel(origin.x + spark.x, origin.y + spark.y, Color(c[4], 0.8))
