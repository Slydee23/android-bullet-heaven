extends SceneTree
## Erzeugt den Platzhalter für das Magiegeschoss (16×16, 4 Frames, Blick nach Osten, Schweif links)
## und die kreisende Klinge des Schwerts (sword_orbit.png, 32×32, Spitze nach Osten).
## Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_weapon_placeholders.gd
## Die Farben werden auf die gemeinsame Palette der Spielwelt (tools/palette.gd) eingefärbt, damit das Geschoss zum Helden passt
## (der Held hält eine blaue Kugel). Die Datei lässt sich jederzeit durch ein Alpha-Asset überschreiben (gleicher Name, beliebig viele 16×16-Frames).
const FRAME := 16
const FRAMES := 4
const OUT := "res://assets/sprites/weapons/magic_bolt.png"

var CORE := Palette.snap(Color("#e0fffd"))
var MID := Palette.snap(Color("#7fc8e0"))
var OUTER := Palette.snap(Color("#3f7090"))
var GOLD := Palette.snap(Color("#f9c769"))

const SWORD_SIZE := 32
const SWORD_OUT := "res://assets/sprites/weapons/sword_orbit.png"
var SWORD_OUTLINE := Palette.snap(Color("#0c0d0f"))
var BLADE_WHITE := Palette.snap(Color("#f4f6f0"))
var STEEL_LIGHT := Palette.snap(Color("#8ecbdc"))
var STEEL := Palette.snap(Color("#6898b2"))
var STEEL_DARK := Palette.snap(Color("#404a66"))
var GOLD_LIGHT := Palette.snap(Color("#f9c769"))
var GOLD_MID := Palette.snap(Color("#cb8038"))
var GOLD_DARK := Palette.snap(Color("#a45b30"))
var LEATHER := Palette.snap(Color("#784030"))
var LEATHER_DARK := Palette.snap(Color("#542a4d"))


func _init() -> void:
	var sheet := Image.create_empty(FRAME * FRAMES, FRAME, false, Image.FORMAT_RGBA8)
	for f in FRAMES:
		_draw_frame(sheet, f)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT).get_base_dir())
	sheet.save_png(OUT)
	_sword_orbit().save_png(SWORD_OUT)
	print("ok")
	quit()


## Kreisende Klinge des Schwerts: 32×32, Stahl-Kurzschwert waagerecht, Spitze nach Osten.
## Im Spiel wird das Bild so gedreht, dass die Spitze immer vom Helden weg zeigt. Licht von oben.
func _sword_orbit() -> Image:
	var img := Image.create_empty(SWORD_SIZE, SWORD_SIZE, false, Image.FORMAT_RGBA8)
	var mid := 15
	# Knauf
	for y in range(mid - 1, mid + 2):
		for x in range(4, 7):
			var corner := (x == 4 or x == 6) and y != mid
			if not corner:
				_px(img, x, y, GOLD_LIGHT if y < mid else GOLD_DARK if y > mid else GOLD_MID)
	# Griff mit Lederwicklung
	for x in range(7, 11):
		_px(img, x, mid, LEATHER_DARK if x % 2 == 0 else LEATHER)
	# Parierstange (senkrecht)
	for y in range(mid - 4, mid + 5):
		_px(img, 11, y, GOLD_LIGHT if y < mid - 1 else GOLD_DARK if y > mid + 1 else GOLD_MID)
		_px(img, 12, y, GOLD_DARK)
	# Klinge: oben hell, Mitte mit Hohlkehle, unten dunkel, die letzten Pixel laufen zur Spitze zusammen
	for x in range(13, 28):
		var to_tip := 28 - x
		_px(img, x, mid, STEEL_LIGHT if to_tip <= 2 else STEEL)
		if to_tip > 1:
			_px(img, x, mid - 1, BLADE_WHITE)
			_px(img, x, mid + 1, STEEL_DARK)
	_px(img, 28, mid, BLADE_WHITE)
	_outline(img)
	return img


## Dunkler 1-px-Rand um alles Gezeichnete
func _outline(img: Image) -> void:
	var edge: Array[Vector2i] = []
	var w := img.get_width()
	var h := img.get_height()
	for y in h:
		for x in w:
			if img.get_pixel(x, y).a > 0.0:
				continue
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n: Vector2i = Vector2i(x, y) + d
				if n.x >= 0 and n.y >= 0 and n.x < w and n.y < h and img.get_pixel(n.x, n.y).a > 0.0:
					edge.append(Vector2i(x, y))
					break
	for e in edge:
		img.set_pixel(e.x, e.y, SWORD_OUTLINE)


func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)


## Kugel mit pulsierender Hülle und flackerndem Schweif nach links
func _draw_frame(sheet: Image, f: int) -> void:
	var ox := f * FRAME
	var center := Vector2(10.0, 7.5)
	var pulse: float = [0.0, 0.5, 1.0, 0.5][f]
	var outer_r := 3.6 + pulse * 0.6
	for y in FRAME:
		for x in FRAME:
			var d := Vector2(x + 0.5, y + 0.5).distance_to(center)
			if d <= 1.6:
				_px(sheet, ox + x, y, CORE)
			elif d <= 2.6:
				_px(sheet, ox + x, y, MID)
			elif d <= outer_r:
				_px(sheet, ox + x, y, OUTER)
	# Schweif: kurze Striche, die pro Frame anders flackern
	for i in range(1, 8):
		var x := 6 - i
		var wobble := int(round(sin((i + f * 2) * 1.3)))
		var c := MID if i < 3 else OUTER
		_px(sheet, ox + x, 7 + wobble, c)
		if i < 5 and (i + f) % 2 == 0:
			_px(sheet, ox + x, 8 + wobble, OUTER)
	# Goldene Funken
	_px(sheet, ox + 3 + (f * 3) % 5, 4 + (f % 2) * 7, GOLD)
