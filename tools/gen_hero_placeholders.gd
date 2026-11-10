extends SceneTree
## Erzeugt Platzhalter für die Treffer- und Tod-Animation des Helden aus dem ersten Frame von hero_idle.png.
## Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_hero_placeholders.gd
## Die Dateien lassen sich jederzeit durch echte Animationen überschreiben (gleicher Name, beliebig viele Frames).
const FRAME := 32
const SOURCE := "res://assets/sprites/characters/hero_idle.png"
const OUT := "res://assets/sprites/characters/"
const HIT_FRAMES := 2
const DEATH_FRAMES := 6
## Drehpunkt (die Füße) im Frame
const FEET := Vector2(16.0, 31.0)
## Am Ende liegt der Held links vom Fußpunkt, deshalb wandert der Drehpunkt nach rechts und etwas nach oben
const LYING_PIVOT := Vector2(25.0, 27.0)


func _init() -> void:
	var source := Image.load_from_file(SOURCE)
	source.convert(Image.FORMAT_RGBA8)
	var base := source.get_region(Rect2i(0, 0, FRAME, FRAME))
	_make_hit(base).save_png(OUT + "hero_hit.png")
	_make_death(base).save_png(OUT + "hero_death.png")
	print("ok")
	quit()


## Frame 1: nach hinten gestaucht und hell aufblitzend, Frame 2: schon wieder fast normal
func _make_hit(base: Image) -> Image:
	var sheet := Image.create_empty(FRAME * HIT_FRAMES, FRAME, false, Image.FORMAT_RGBA8)
	for f in HIT_FRAMES:
		var shift := -2 + f
		var tint := 0.3 if f == 0 else 0.1
		var frame := Image.create_empty(FRAME, FRAME, false, Image.FORMAT_RGBA8)
		for y in FRAME:
			# Oberkörper kippt leicht nach hinten, die Füße bleiben stehen
			var lean := int(round(shift * (1.0 - y / float(FRAME - 1))))
			for x in FRAME:
				var sx := x - lean
				if sx < 0 or sx >= FRAME:
					continue
				var c := base.get_pixel(sx, y)
				if c.a > 0.0:
					frame.set_pixel(x, y, Color(c.r, c.g, c.b, c.a).lerp(Color(1, 1, 1, c.a), tint))
		sheet.blit_rect(frame, Rect2i(0, 0, FRAME, FRAME), Vector2i(f * FRAME, 0))
	return sheet


## Kippt Schritt für Schritt nach hinten (links) um und bleibt liegen, die letzten Frames werden dunkler
func _make_death(base: Image) -> Image:
	var sheet := Image.create_empty(FRAME * DEATH_FRAMES, FRAME, false, Image.FORMAT_RGBA8)
	for f in DEATH_FRAMES:
		var t := f / float(DEATH_FRAMES - 1)
		# Schnell weg vom Stehen, am Ende sanft aufkommen
		var fall := 1.0 - pow(1.0 - t, 2.0)
		var angle := -deg_to_rad(90.0) * fall
		var pivot := FEET.lerp(LYING_PIVOT, fall)
		var dim := lerpf(1.0, 0.6, t)
		var frame := Image.create_empty(FRAME, FRAME, false, Image.FORMAT_RGBA8)
		for y in FRAME:
			for x in FRAME:
				# Rückwärts: Welches Pixel des stehenden Helden landet an dieser Stelle?
				var d := Vector2(x + 0.5, y + 0.5) - pivot
				var src := d.rotated(-angle) + FEET
				var sx := int(floor(src.x))
				var sy := int(floor(src.y))
				if sx < 0 or sx >= FRAME or sy < 0 or sy >= FRAME:
					continue
				var c := base.get_pixel(sx, sy)
				if c.a > 0.0:
					frame.set_pixel(x, y, Color(c.r * dim, c.g * dim, c.b * dim, c.a))
		sheet.blit_rect(frame, Rect2i(0, 0, FRAME, FRAME), Vector2i(f * FRAME, 0))
	return sheet
