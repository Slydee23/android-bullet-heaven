class_name WeaponSlots
extends Control
## Die 4 Waffenplätze klein im HUD: Icon und Level, Startwaffe mit Goldrand. Nur Anzeige, Berührungen gehen durch.
## Zeichnet alles in einem _draw und nur neu, wenn sich die Waffen ändern.

const PixelUI := preload("res://scripts/ui/pixel_ui.gd")
const SLOT := preload("res://assets/ui/hud_slot.png")
const SLOT_START := preload("res://assets/ui/hud_slot_start.png")
const SLOT_MARGIN := 3
## Größe eines Platzes und Abstand (Bildschirm-Pixel); das 32er-Icon wird 2× gezeichnet
const SLOT_SIZE := 80.0
const GAP := 8.0
const ICON_SCALE := 2.0
## Freie Plätze werden blass gezeichnet
const EMPTY_MODULATE := Color(1.0, 1.0, 1.0, 0.45)
const LEVEL_FONT_SIZE := 32

var _weapons: WeaponHolder
var _slot_style: StyleBoxTexture
var _start_style: StyleBoxTexture


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_slot_style = PixelUI.nine_slice(SLOT, SLOT_MARGIN)
	_start_style = PixelUI.nine_slice(SLOT_START, SLOT_MARGIN)
	var slots := WeaponHolder.START_SLOTS + WeaponHolder.RUN_SLOTS
	custom_minimum_size = Vector2(slots * SLOT_SIZE + (slots - 1) * GAP, SLOT_SIZE)


func bind_hud(_player: Player, _run_state: RunState, weapons: WeaponHolder) -> void:
	_weapons = weapons
	weapons.weapons_changed.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if not _weapons:
		return
	var index := 0
	for k in WeaponHolder.START_SLOTS:
		_draw_slot(index, _weapons.start_weapons[k] if k < _weapons.start_weapons.size() else null, true)
		index += 1
	for k in WeaponHolder.RUN_SLOTS:
		_draw_slot(index, _weapons.run_weapons[k] if k < _weapons.run_weapons.size() else null, false)
		index += 1


func _draw_slot(index: int, weapon: WeaponInstance, start: bool) -> void:
	var rect := Rect2(Vector2(index * (SLOT_SIZE + GAP), 0.0), Vector2(SLOT_SIZE, SLOT_SIZE))
	var style := _start_style if start else _slot_style
	style.modulate_color = Color.WHITE if weapon else EMPTY_MODULATE
	draw_style_box(style, rect)
	if not weapon or not weapon.data.icon:
		return
	var icon_size := weapon.data.icon.get_size() * ICON_SCALE
	draw_texture_rect(weapon.data.icon, Rect2(rect.get_center() - icon_size * 0.5, icon_size), false)
	# Level unten rechts, mit Schatten wie alle Pixel-Texte
	var font := PixelUI.FONT
	var text := str(weapon.level)
	var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LEVEL_FONT_SIZE).x
	var baseline := rect.end - Vector2(text_width + 8.0, 8.0)
	draw_string(font, baseline + Vector2(PixelUI.SHADOW_OFFSET), text, HORIZONTAL_ALIGNMENT_LEFT, -1, LEVEL_FONT_SIZE, PixelUI.OUTLINE_COLOR)
	draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, LEVEL_FONT_SIZE, PixelUI.TEXT_COLOR)
