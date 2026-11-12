class_name DamageNumberManager
extends Node2D
## Zeigt alle Schadenszahlen zentral an, wie EffectManager und EnemyManager: feste Arrays (Pool), ein Zeichendurchgang.
## Die Zahlen liegen in einer eigenen CanvasLayer und werden in Bildschirm-Koordinaten gezeichnet, nicht in der Spielwelt.
## So bleiben sie bei jedem Kamera-Zoom gleich groß und lesbar. Die Ziffern sind eigene Pixel-Grafik (damage_digits.png,
## Generator tools/gen_damage_digits.gd), ganzzahlig vergrößert: Normal Stufe 3, kritisch oder tödlich 4, beides 5.
## Ein kritischer Treffer startet eine Stufe größer und setzt sich dann (Ploppen).

const DIGITS := preload("res://assets/sprites/effects/damage_digits.png")
## Zelle einer Ziffer im Bild (Körper 7×9 plus Rand und Schatten) und Abstand von Ziffer zu Ziffer
const CELL := Vector2(10.0, 12.0)
const ADVANCE := 8.0
const EXCLAMATION := 10
const MAX_NUMBERS := 64
## Lebensdauer in Sekunden: normal, kritisch, tödlich, kritisch und tödlich (tödliche Zahlen bleiben länger stehen)
const LIFETIMES := [0.6, 0.8, 1.0, 1.2]
## So weit steigt eine Zahl in Bildschirm-Pixeln
const RISE := 70.0
## Die Zahl blendet in diesem Anteil ihrer Lebensdauer am Ende aus
const FADE_SHARE := 0.3
## So lange (Sekunden) ist ein kritischer Treffer größer, bevor er sich setzt
const POP_TIME := 0.1
## Vergrößerung der Ziffern (ganzzahlig, damit die Pixel scharf bleiben)
const SCALE_NORMAL := 3
const SCALE_BIG := 4
const SCALE_HUGE := 5

var count := 0

var _world_positions := PackedVector2Array()
var _ages := PackedFloat32Array()
var _lifetimes := PackedFloat32Array()
var _scales := PackedInt32Array()
var _crits := PackedByteArray()
var _colors := PackedColorArray()
## Der Text wird nur beim Erzeugen einer Zahl gebaut, nicht jeden Frame
var _texts: Array[String] = []
var _was_drawn := false


func _ready() -> void:
	_world_positions.resize(MAX_NUMBERS)
	_ages.resize(MAX_NUMBERS)
	_lifetimes.resize(MAX_NUMBERS)
	_scales.resize(MAX_NUMBERS)
	_crits.resize(MAX_NUMBERS)
	_colors.resize(MAX_NUMBERS)
	_texts.resize(MAX_NUMBERS)


## Neue Zahl an der Weltposition pos (Körpermitte). Ist der Pool voll, wird die älteste Zahl überschrieben.
func spawn(pos: Vector2, amount: float, element: StringName, crit: bool, kill: bool) -> void:
	var slot := count
	if count >= MAX_NUMBERS:
		slot = 0
		for i in count:
			if _ages[i] > _ages[slot]:
				slot = i
	else:
		count += 1
	var kind := (1 if crit else 0) + (2 if kill else 0)
	_world_positions[slot] = pos + Vector2(randf_range(-6.0, 6.0), 0.0)
	_ages[slot] = 0.0
	_lifetimes[slot] = LIFETIMES[kind]
	_scales[slot] = [SCALE_NORMAL, SCALE_BIG, SCALE_BIG, SCALE_HUGE][kind]
	_crits[slot] = 1 if crit else 0
	_colors[slot] = Elements.damage_color(element, crit)
	_texts[slot] = "%d%s" % [maxi(1, roundi(amount)), "!" if crit else ""]


func _process(delta: float) -> void:
	# Rückwärts, weil das Entfernen die letzte Zahl auf den freien Platz setzt
	for i in range(count - 1, -1, -1):
		_ages[i] += delta
		if _ages[i] >= _lifetimes[i]:
			count -= 1
			_world_positions[i] = _world_positions[count]
			_ages[i] = _ages[count]
			_lifetimes[i] = _lifetimes[count]
			_scales[i] = _scales[count]
			_crits[i] = _crits[count]
			_colors[i] = _colors[count]
			_texts[i] = _texts[count]
	if count > 0 or _was_drawn:
		queue_redraw()


func _draw() -> void:
	_was_drawn = count > 0
	var to_screen := get_viewport().get_canvas_transform()
	for i in count:
		var progress := _ages[i] / _lifetimes[i]
		var zoom := _scales[i]
		if _crits[i] == 1 and _ages[i] < POP_TIME:
			zoom += 1
		var color := _colors[i]
		if progress > 1.0 - FADE_SHARE:
			color.a = (1.0 - progress) / FADE_SHARE
		var text := _texts[i]
		var cell := CELL * zoom
		# Mitte der Zahl über dem Anker, Unterkante der Ziffern auf dem Anker
		var anchor := (to_screen * _world_positions[i] - Vector2(0.0, RISE * progress)).round()
		var x := roundf(anchor.x - (text.length() * ADVANCE * zoom) * 0.5)
		for k in text.length():
			var code := text.unicode_at(k) - 48
			var index := EXCLAMATION if code < 0 or code > 9 else code
			draw_texture_rect_region(DIGITS, Rect2(Vector2(x + k * ADVANCE * zoom, anchor.y - cell.y), cell), Rect2(Vector2(index * CELL.x, 0.0), CELL), color)
