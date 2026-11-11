extends SceneTree
## Erzeugt den Platzhalter für das Magiegeschoss: 16×16, 4 Frames, Blick nach Osten (Schweif links).
## Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_weapon_placeholders.gd
## Die Datei lässt sich jederzeit durch ein Alpha-Asset überschreiben (gleicher Name, beliebig viele 16×16-Frames).
const FRAME := 16
const FRAMES := 4
const OUT := "res://assets/sprites/weapons/magic_bolt.png"
const CORE := Color("#fff4d0")
const MID := Color("#b49cff")
const OUTER := Color("#7a5cd0")
const GOLD := Color("#f6dc90")


func _init() -> void:
	var sheet := Image.create_empty(FRAME * FRAMES, FRAME, false, Image.FORMAT_RGBA8)
	for f in FRAMES:
		_draw_frame(sheet, f)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT).get_base_dir())
	sheet.save_png(OUT)
	print("ok")
	quit()


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
