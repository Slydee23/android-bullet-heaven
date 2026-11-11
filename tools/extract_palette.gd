extends SceneTree
## Liest die Farben der vorhandenen Spielwelt-Texturen (Held, Skelett) aus und schreibt die häufigsten nach tools/palette.gd.
## So nutzen alle Platzhalter-Generatoren dieselbe Farbpalette wie die Pixellab-Figuren und passen optisch dazu.
## Aufruf (im Projektordner): Godot --headless --path . -s tools/extract_palette.gd
## Die Datei tools/palette.gd darf danach von Hand angepasst werden.

const SOURCES := [
	"res://assets/sprites/characters/hero_idle.png",
	"res://assets/sprites/characters/hero_run.png",
	"res://assets/sprites/enemies/skeleton_walk.png",
]
const OUT := "res://tools/palette.gd"
const MAX_COLORS := 32
## Farben, die näher als das beieinander liegen (RGB-Abstand 0..1,73), gelten als dieselbe Farbe
const MIN_DISTANCE := 0.09
## Fast durchsichtige Pixel (Kanten) zählen nicht mit
const MIN_ALPHA := 0.9


func _init() -> void:
	var counts: Dictionary[int, int] = {}
	for path in SOURCES:
		var image := Image.load_from_file(path)
		image.convert(Image.FORMAT_RGBA8)
		for y in image.get_height():
			for x in image.get_width():
				var c := image.get_pixel(x, y)
				if c.a < MIN_ALPHA:
					continue
				var key := c.to_rgba32() | 0xFF
				counts[key] = counts.get(key, 0) + 1
	var keys: Array = counts.keys()
	keys.sort_custom(func(a: int, b: int) -> bool: return counts[a] > counts[b])
	var palette: Array[Color] = []
	for key: int in keys:
		var c := Color.hex(key)
		var is_new := true
		for p in palette:
			if _distance(c, p) < MIN_DISTANCE:
				is_new = false
				break
		if is_new:
			palette.append(c)
			if palette.size() >= MAX_COLORS:
				break
	_write(palette, counts.size())
	print("ok: ", palette.size(), " Farben aus ", counts.size(), " verschiedenen")
	quit()


func _distance(a: Color, b: Color) -> float:
	return Vector3(a.r - b.r, a.g - b.g, a.b - b.b).length()


func _write(palette: Array[Color], total: int) -> void:
	var lines := PackedStringArray()
	lines.append("class_name Palette")
	lines.append("extends RefCounted")
	lines.append("## Gemeinsame Farbpalette der Spielwelt-Grafiken. Erzeugt von tools/extract_palette.gd aus Held und Skelett")
	lines.append("## (%d Farben aus %d verschiedenen), darf von Hand angepasst werden." % [palette.size(), total])
	lines.append("## Platzhalter-Generatoren der Spielwelt (nicht der UI) färben ihre Bilder mit snap() auf diese Farben ein.")
	lines.append("")
	lines.append("const COLORS: Array[Color] = [")
	for c in palette:
		lines.append("\tColor(\"#%s\")," % c.to_html(false))
	lines.append("]")
	lines.append("")
	lines.append("")
	lines.append("## Die Palettenfarbe, die c am nächsten liegt (Alpha bleibt erhalten).")
	lines.append("static func snap(c: Color) -> Color:")
	lines.append("\tvar best := COLORS[0]")
	lines.append("\tvar best_distance := INF")
	lines.append("\tfor p in COLORS:")
	lines.append("\t\tvar d := Vector3(c.r - p.r, c.g - p.g, c.b - p.b).length_squared()")
	lines.append("\t\tif d < best_distance:")
	lines.append("\t\t\tbest_distance = d")
	lines.append("\t\t\tbest = p")
	lines.append("\treturn Color(best, c.a)")
	var file := FileAccess.open(OUT, FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
