extends SceneTree
## Erzeugt die HUD-Texturen im Stil „Runenstein & Bann-Siegel“ (wie tools/gen_ui.gd, eigene Datei, damit die
## Menü-Grafiken unberührt bleiben). Aufruf (im Projektordner): Godot --headless --path . -s tools/gen_hud.gd
## Schreibt nach assets/ui/. Alle Dateien lassen sich durch eigene Alpha-Assets (gleicher Name, gleiche Größe) ersetzen.
## Im Spiel werden sie wie alle UI-Texturen 4× vergrößert.

const OUT := "res://assets/ui/"

const OUTLINE := Color("#0a0710")
const STONE_HI := Color("#6a5b8c")
const STONE_LIGHT := Color("#4a3f66")
const STONE := Color("#35294d")
const STONE_DARK := Color("#2a2240")
const STONE_DEEP := Color("#1c1629")
const TROUGH := Color("#0f0b18")
const GOLD_HI := Color("#f6dc90")
const GOLD := Color("#e0b050")
const GOLD_MID := Color("#a87a2a")
const GOLD_DARK := Color("#6b4a1a")
# Blutrot (Leben) und Seelenblau (Erfahrung), von hell (Oberkante) nach dunkel (Unterkante)
const BLOOD := [Color("#e0525a"), Color("#b0202e"), Color("#951a27"), Color("#680d19")]
const SOUL := [Color("#cdfcfa"), Color("#62b8da"), Color("#4f9fc8"), Color("#376281")]


func _init() -> void:
	_bar_frame().save_png(OUT + "hud_bar_frame.png")
	_fill(BLOOD).save_png(OUT + "hud_fill_hp.png")
	_fill(SOUL).save_png(OUT + "hud_fill_xp.png")
	_heart().save_png(OUT + "hud_heart.png")
	_slot(false).save_png(OUT + "hud_slot.png")
	_slot(true).save_png(OUT + "hud_slot_start.png")
	_card(["#e8e0f0", "#b8b0c8", "#6a6478"]).save_png(OUT + "card_common.png")
	_card(["#cdfcfa", "#62b8da", "#376281"]).save_png(OUT + "card_rare.png")
	_card(["#f6f0ff", "#b49cff", "#4a2f8c"]).save_png(OUT + "card_epic.png")
	print("ok")
	quit()


func _new(w: int, h: int) -> Image:
	return Image.create_empty(w, h, false, Image.FORMAT_RGBA8)


func _ring(x: int, y: int, w: int, h: int, radius: int) -> int:
	var dx := mini(x, w - 1 - x)
	var dy := mini(y, h - 1 - y)
	if dx < radius and dy < radius:
		var dist := Vector2(radius - (dx + 0.5), radius - (dy + 0.5)).length()
		if dist > radius:
			return -1
		return int(floor(radius - dist))
	return mini(dx, dy)


func _lit(x: int, y: int, w: int, h: int) -> bool:
	var dx := mini(x, w - 1 - x)
	var dy := mini(y, h - 1 - y)
	if dy < dx:
		return y < h / 2
	if dx < dy:
		return x < w / 2
	return (x + y) < (w + h) / 2


func _frame(w: int, h: int, radius: int, layers: Array, fill: Color) -> Image:
	var img := _new(w, h)
	for y in h:
		for x in w:
			var r := _ring(x, y, w, h, radius)
			if r < 0:
				continue
			if r < layers.size():
				img.set_pixel(x, y, layers[r][0] if _lit(x, y, w, h) else layers[r][1])
			else:
				img.set_pixel(x, y, fill)
	return img


## 16×10, 9-Slice mit Rand 3: Steinfassung mit Goldkante, innen eine dunkle Rinne (4 px hoch) für die Füllung
func _bar_frame() -> Image:
	var layers := [
		[OUTLINE, OUTLINE],
		[GOLD, GOLD_DARK],
		[STONE_DEEP, STONE_LIGHT],
	]
	return _frame(16, 10, 2, layers, TROUGH)


## 1×4: Füllung der Leiste (wird auf die Rinne gestreckt), helle Oberkante, dunkle Unterkante
func _fill(colors: Array) -> Image:
	var img := _new(1, 4)
	for y in 4:
		img.set_pixel(0, y, colors[y])
	return img


## 9×8: Blutrotes Herz mit Umriss und Glanzpunkt
func _heart() -> Image:
	var rows := [
		".XX...XX.",
		"XhhX.XrrX",
		"XhrrXrrrX",
		"XrrrrrrdX",
		".XrrrrdX.",
		"..XrrdX..",
		"...XdX...",
		"....X....",
	]
	var img := _new(9, 8)
	for y in rows.size():
		for x in 9:
			match rows[y][x]:
				"X": img.set_pixel(x, y, OUTLINE)
				"h": img.set_pixel(x, y, BLOOD[0])
				"r": img.set_pixel(x, y, BLOOD[1])
				"d": img.set_pixel(x, y, BLOOD[3])
	return img


## 10×10, 9-Slice mit Rand 3: Waffenplatz. Startwaffe mit Goldrand, Run-Plätze mit Steinrand.
func _slot(start: bool) -> Image:
	var layers := [
		[OUTLINE, OUTLINE],
		[GOLD, GOLD_DARK] if start else [STONE_HI, STONE_DARK],
		[STONE_DEEP, STONE_DEEP],
	]
	var img := _frame(10, 10, 2, layers, Color(STONE_DARK, 0.85))
	return img


## 24×24, 9-Slice mit Rand 8: Level-Up-Karte wie die Menü-Fenster (Stein, innen Goldlinie), außen ein Rand in der Seltenheitsfarbe.
## rarity = [hell, Grund, dunkel]
func _card(rarity: Array) -> Image:
	var hi := Color(rarity[0])
	var mid := Color(rarity[1])
	var dark := Color(rarity[2])
	var layers := [
		[OUTLINE, OUTLINE],
		[hi, dark],
		[mid, dark],
		[OUTLINE, OUTLINE],
		[STONE_LIGHT, STONE_DARK],
		[GOLD, GOLD_DARK],
		[Color("#100c18"), Color("#100c18")],
	]
	return _frame(24, 24, 4, layers, Color("#17121f"))
