extends SceneTree
## Erzeugt die Übungspuppe für das Debug-Menü: assets/sprites/enemies/training_dummy.png (32×32, 1 Frame, Blick nach Osten).
## Strohpuppe am Holzpfahl: Pfahl steckt unten im Boden (Fußpunkt unten in der Mitte), Querholz als Arme mit Strohbüscheln,
## Körper aus Sackleinen mit Seilwicklungen, runder Sackleinen-Kopf mit aufgenähten X-Augen. Licht von oben links.
## Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_training_dummy.gd
const SIZE := 32
const OUT := "res://assets/sprites/enemies/training_dummy.png"

var OUTLINE := Palette.snap(Color("#0c0d0f"))
var WOOD_LIGHT := Palette.snap(Color("#8a6e52"))
var WOOD := Palette.snap(Color("#514043"))
var WOOD_DARK := Palette.snap(Color("#332930"))
var CLOTH_LIGHT := Palette.snap(Color("#ddd4b5"))
var CLOTH := Palette.snap(Color("#cdbf9b"))
var CLOTH_DARK := Palette.snap(Color("#9a8163"))
var ROPE := Palette.snap(Color("#784030"))
var STRAW_LIGHT := Palette.snap(Color("#f9c769"))
var STRAW := Palette.snap(Color("#cb8038"))
var STITCH := Palette.snap(Color("#332930"))


func _init() -> void:
	var img := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	# Pfahl: von unten bis in den Körper, 3 px breit
	for y in range(7, 32):
		_px(img, 15, y, WOOD_LIGHT)
		_px(img, 16, y, WOOD)
		_px(img, 17, y, WOOD_DARK)
	# Querholz (Arme) mit Strohbüscheln an den Enden
	for x in range(6, 27):
		_px(img, x, 13, WOOD_LIGHT)
		_px(img, x, 14, WOOD_DARK)
	for p in [Vector2i(4, 12), Vector2i(5, 13), Vector2i(4, 14), Vector2i(3, 13), Vector2i(5, 15)]:
		_px(img, p.x, p.y, STRAW_LIGHT if p.y < 14 else STRAW)
	for p in [Vector2i(27, 12), Vector2i(28, 13), Vector2i(27, 14), Vector2i(29, 13), Vector2i(28, 15)]:
		_px(img, p.x, p.y, STRAW_LIGHT if p.y < 14 else STRAW)
	# Körper: Sackleinen-Oval, Licht von oben links
	var body := Vector2(16.0, 17.0)
	for y in range(10, 24):
		for x in range(9, 24):
			var q := (Vector2(x + 0.5, y + 0.5) - body) / Vector2(6.0, 5.8)
			if q.length() > 1.0:
				continue
			var shade := q.dot(Vector2(-1, -1).normalized())
			_px(img, x, y, CLOTH_LIGHT if shade > 0.35 else CLOTH_DARK if shade < -0.3 else CLOTH)
	# Seilwicklungen um den Körper
	for x in range(10, 23):
		if Vector2(x + 0.5 - body.x, 0).length() < 6.0:
			_px(img, x, 15, ROPE)
			_px(img, x, 20, ROPE)
	# Stroh schaut unten aus dem Sack
	for p in [Vector2i(13, 23), Vector2i(14, 24), Vector2i(18, 23), Vector2i(19, 24), Vector2i(12, 22)]:
		_px(img, p.x, p.y, STRAW)
	# Kopf: rundes Sackleinen, X-Augen, ein Stroh-Schopf oben
	var head := Vector2(16.0, 4.6)
	for y in range(0, 10):
		for x in range(11, 22):
			var q := (Vector2(x + 0.5, y + 0.5) - head) / 4.1
			if q.length() > 1.0:
				continue
			var shade := q.dot(Vector2(-1, -1).normalized())
			_px(img, x, y, CLOTH_LIGHT if shade > 0.35 else CLOTH_DARK if shade < -0.3 else CLOTH)
	for p in [Vector2i(17, 3), Vector2i(19, 3), Vector2i(18, 4), Vector2i(17, 5), Vector2i(19, 5)]:
		_px(img, p.x, p.y, STITCH)
	_px(img, 14, 4, STITCH)
	for p in [Vector2i(15, 0), Vector2i(16, 0), Vector2i(14, 1)]:
		_px(img, p.x, p.y, STRAW_LIGHT)
	_outline(img)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT).get_base_dir())
	img.save_png(OUT)
	print("ok")
	quit()


func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < SIZE and y < SIZE:
		img.set_pixel(x, y, c)


## Dunkler 1-px-Rand (4 Nachbarn) um alles Gezeichnete. Der unterste Rand bleibt frei, dort steckt der Pfahl im Boden.
func _outline(img: Image) -> void:
	var edge: Array[Vector2i] = []
	for y in SIZE:
		for x in SIZE:
			if img.get_pixel(x, y).a > 0.0:
				continue
			for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n := Vector2i(x, y) + d
				if n.x >= 0 and n.y >= 0 and n.x < SIZE and n.y < SIZE and img.get_pixel(n.x, n.y).a > 0.0:
					edge.append(Vector2i(x, y))
					break
	for e in edge:
		img.set_pixel(e.x, e.y, OUTLINE)
