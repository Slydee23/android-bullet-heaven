extends SceneTree
## Erzeugt die Icons der Helden-Boni und der Heilungskarte als „Runen-Siegel“: runder dunkler Runenstein mit Goldrand,
## darauf ein leuchtendes Symbol. Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_bonus_icons.gd
## Schreibt nach assets/sprites/icons/bonus_*.png (32×32). Ersetzbar durch Alpha-Assets mit gleichem Namen.

const OUT := "res://assets/sprites/icons/"
const SIZE := 32
const CENTER := Vector2(15.5, 15.5)

const OUTLINE := Color("#0a0710")
const GOLD_HI := Color("#f6dc90")
const GOLD := Color("#e0b050")
const GOLD_DARK := Color("#6b4a1a")
const STONE_LIGHT := Color("#4a3f66")
const STONE := Color("#35294d")
const STONE_DEEP := Color("#1c1629")

## Symbole auf 14×14: x = Grundfarbe, h = hell, d = dunkel
const GLYPHS := {
	"damage": [
		"...........hh.",
		"..........hxx.",
		".........hxxd.",
		"........hxxd..",
		".......hxxd...",
		"......hxxd....",
		".....hxxd.....",
		"..d.hxxd......",
		"..dxxxd.......",
		"...dxd........",
		"..dxdxd.......",
		".dxd..dd......",
		".dd...........",
		"..............",
	],
	"cooldown": [
		"..dddddddddd..",
		"..dhhhhhhhhd..",
		"...dxxxxxxd...",
		"....dxxxxd....",
		".....dxxd.....",
		"......dd......",
		"......xd......",
		".....d..d.....",
		"....d..h.d....",
		"...d..hxx.d...",
		"..dhxxxxxxxd..",
		"..dhhhhhhhhd..",
		"..dddddddddd..",
		"..............",
	],
	"speed": [
		"..............",
		"....hhhh......",
		"hh..hxxd......",
		"hxh.hxxd......",
		".hxhhxxd......",
		"..hxhxxd......",
		"....hxxd......",
		"....hxxxd.....",
		"....hxxxxxd...",
		"....hxxxxxxd..",
		"....dddddddd..",
		"..............",
		"..............",
		"..............",
	],
	"max_hp": [
		"..............",
		"..dd....dd....",
		".dhhd..dxxd...",
		"dhhxxddxxxxd..",
		"dhxxxxxxxxxd..",
		"dxxxxxxxxxxd..",
		".dxxxxxxxxd...",
		"..dxxxxxxd....",
		"...dxxxxd.....",
		"....dxxd......",
		".....dd.......",
		"..............",
		"..............",
		"..............",
	],
	"pickup": [
		"..............",
		"..d........d..",
		".d....hh....d.",
		"d....hxxd....d",
		"d...hxxxxd...d",
		"d...hxxxxd...d",
		".d..hxxxxd..d.",
		"..d..hxxd..d..",
		"......hd......",
		"..............",
		".d..........d.",
		"..dd......dd..",
		"....dddddd....",
		"..............",
	],
	"amount": [
		"..............",
		"..h.......h...",
		"..hx......hx..",
		"..hxx.....hxx.",
		"hhhxxxhhhhhxxx",
		"xxxxxxxxxxxxxx",
		"dddxxxdddddxxx",
		"..dxx.....dxx.",
		"..dx......dx..",
		"..d.......d...",
		"..............",
		"..............",
		"..............",
		"..............",
	],
	"heal": [
		"..............",
		"..dd....dd....",
		".dhhd..dxxd...",
		"dhhxxddxxxxd..",
		"dhxxxhhxxxxd..",
		"dxxxxhhxxxxd..",
		".dxhhhhhhxd...",
		"..dxxhhxxd....",
		"...dxhhxd.....",
		"....dxxd......",
		".....dd.......",
		"..............",
		"..............",
		"..............",
	],
}
## Farben je Symbol: [hell, Grund, dunkel]
const COLORS := {
	"damage": ["#ffd0c0", "#e0525a", "#680d19"],
	"cooldown": ["#fff3b0", "#f9c769", "#a45b30"],
	"speed": ["#e0ffd0", "#8fdc7a", "#2f7a45"],
	"max_hp": ["#ffb0b0", "#e0525a", "#680d19"],
	"pickup": ["#effffe", "#62b8da", "#376281"],
	"amount": ["#f6f0ff", "#b49cff", "#4a2f8c"],
	"heal": ["#efffe0", "#e0525a", "#680d19"],
}


func _init() -> void:
	for key in GLYPHS.keys():
		_icon(key).save_png(OUT + "bonus_%s.png" % key)
	print("ok")
	quit()


func _icon(key: String) -> Image:
	var img := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	# Runenstein: Umriss, Goldring, Stein mit Licht oben links
	for y in SIZE:
		for x in SIZE:
			var d := Vector2(x, y).distance_to(CENTER)
			if d > 15.0:
				continue
			var lit := (x + y) < 31
			var color: Color
			if d > 14.0:
				color = OUTLINE
			elif d > 12.5:
				color = GOLD_HI if lit and d < 13.3 else (GOLD if lit else GOLD_DARK)
			elif d > 11.5:
				color = OUTLINE
			else:
				color = STONE if d < 9.0 else (STONE_LIGHT if lit else STONE_DEEP)
			img.set_pixel(x, y, color)
	var palette: Array = COLORS[key]
	var glow := Color(palette[1])
	glow.a = 0.25
	var rows: Array = GLYPHS[key]
	var origin := Vector2i(9, 9)
	# Schwaches Leuchten um das Symbol, dann das Symbol selbst
	for y in rows.size():
		for x in rows[y].length():
			if rows[y][x] != ".":
				for o in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
					var p: Vector2i = origin + Vector2i(x, y) + o
					var old := img.get_pixel(p.x, p.y)
					if old.a > 0.0:
						img.set_pixel(p.x, p.y, old.lerp(Color(glow, 1.0), glow.a))
	for y in rows.size():
		for x in rows[y].length():
			var c: String = rows[y][x]
			if c == ".":
				continue
			var color := Color(palette[0] if c == "h" else (palette[1] if c == "x" else palette[2]))
			img.set_pixel(origin.x + x, origin.y + y, color)
	return img
