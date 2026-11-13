class_name HudBar
extends Control
## Leiste im HUD: Steinfassung (9-Slice) mit einer Füllung in der Rinne, pixelgenau 4× vergrößert.
## Zeichnet nur neu, wenn sich der Füllstand ändert.

const PixelUI := preload("res://scripts/pixel_ui.gd")
const FRAME := preload("res://assets/ui/hud_bar_frame.png")
## Randbreite der Fassung in Pixeln der Originaltextur (dort beginnt die Rinne)
const FRAME_MARGIN := 3

## Füllung (1 Pixel breit, wird gestreckt), z. B. Blutrot für Leben, Seelenblau für Erfahrung
@export var fill_texture: Texture2D

## Füllstand 0..1
var ratio := 0.0:
	set(value):
		value = clampf(value, 0.0, 1.0)
		if value != ratio:
			ratio = value
			queue_redraw()

var _frame_style: StyleBoxTexture


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame_style = PixelUI.nine_slice(FRAME, FRAME_MARGIN)


func _draw() -> void:
	draw_style_box(_frame_style, Rect2(Vector2.ZERO, size))
	var border := float(FRAME_MARGIN * PixelUI.UI_SCALE)
	var inner := Rect2(Vector2(border, border), size - Vector2(border, border) * 2.0)
	# Auf ganze Textur-Pixel runden, damit die Kante so grob bleibt wie der Rest der Pixel-Art
	var width := roundf(inner.size.x * ratio / PixelUI.UI_SCALE) * PixelUI.UI_SCALE
	if width > 0.0 and fill_texture:
		draw_texture_rect(fill_texture, Rect2(inner.position, Vector2(width, inner.size.y)), false)
