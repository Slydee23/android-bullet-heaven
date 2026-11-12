extends SceneTree
## Erzeugt die Ziffern der Schadenszahlen (assets/sprites/effects/damage_digits.png): 0-9 und „!“, dicke runde Pixel-Ziffern.
## Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_damage_digits.gd
## Jede Ziffer ist 7×9 Pixel groß (Striche 2 Pixel dick), liegt in einer 10×12-Zelle und hat einen dunklen Rand und einen
## Schlagschatten nach unten rechts (Licht von oben links). Die Ziffer selbst ist hell, damit das Spiel sie per Modulate
## in der Farbe des Elements einfärben kann. Zeichenreihenfolge im Bild: 0123456789!
const CELL := Vector2i(10, 12)
const GLYPH := Vector2i(7, 9)
const OUT := "res://assets/sprites/effects/damage_digits.png"

const GLYPHS := [
	[".#####.", "##...##", "##...##", "##...##", "##...##", "##...##", "##...##", "##...##", ".#####."],
	["..###..", ".####..", "..###..", "..###..", "..###..", "..###..", "..###..", "..###..", ".#####."],
	[".#####.", "##...##", ".....##", ".....##", "..####.", ".##....", "##.....", "##.....", "#######"],
	[".#####.", "##...##", ".....##", "..####.", "..####.", ".....##", ".....##", "##...##", ".#####."],
	["...###.", "..####.", ".##.##.", "##..##.", "#######", "#######", "....##.", "....##.", "....##."],
	["#######", "##.....", "##.....", "######.", "##...##", ".....##", ".....##", "##...##", ".#####."],
	[".#####.", "##...##", "##.....", "##.....", "######.", "##...##", "##...##", "##...##", ".#####."],
	["#######", ".....##", ".....##", "....##.", "...##..", "...##..", "..##...", "..##...", "..##..."],
	[".#####.", "##...##", "##...##", ".#####.", ".#####.", "##...##", "##...##", "##...##", ".#####."],
	[".#####.", "##...##", "##...##", "##...##", ".######", ".....##", ".....##", "##...##", ".#####."],
	["..###..", "..###..", "..###..", "..###..", "..###..", "..###..", ".......", "..###..", "..###.."],
]

var BODY := Palette.snap(Color("#f4f6f0"))
var SHADE := Palette.snap(Color("#bfc4c0"))
var OUTLINE := Palette.snap(Color("#542a4d"))
var SHADOW := Color(0.05, 0.03, 0.08, 0.6)


func _init() -> void:
	var sheet := Image.create_empty(CELL.x * GLYPHS.size(), CELL.y, false, Image.FORMAT_RGBA8)
	for g in GLYPHS.size():
		_draw_glyph(sheet, g)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT.get_base_dir()))
	sheet.save_png(OUT)
	print("ok")
	quit()


func _body(rows: Array, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < GLYPH.x and y < GLYPH.y and (rows[y] as String)[x] == "#"


func _draw_glyph(sheet: Image, index: int) -> void:
	var rows: Array = GLYPHS[index]
	var ox := index * CELL.x
	# Alle Zellpixel: Körper liegt bei (1,1), Rand 1 Pixel drumherum, Schatten = Rand um (1,1) verschoben
	for y in CELL.y:
		for x in CELL.x:
			var bx := x - 1
			var by := y - 1
			var near_body := false
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if _body(rows, bx + dx, by + dy):
						near_body = true
			var shadow_near := false
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if _body(rows, bx - 1 + dx, by - 1 + dy):
						shadow_near = true
			var color := Color(0, 0, 0, 0)
			if _body(rows, bx, by):
				# Unterste Pixel eines Strichs sind dunkler (Licht kommt von oben)
				color = BODY if _body(rows, bx, by + 1) else SHADE
			elif near_body:
				color = OUTLINE
			elif shadow_near:
				color = SHADOW
			if color.a > 0.0:
				sheet.set_pixel(ox + x, y, color)
