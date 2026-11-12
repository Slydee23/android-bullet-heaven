class_name WeaponCard
extends PanelContainer
## Karte eines Waffenplatzes im Statusbildschirm: Icon, Name, Element, Level-Leiste und die wichtigsten Werte.
## Antippen öffnet das Detailfenster (Signal `pressed`). Ein leerer Platz zeigt nur „Leer“.

signal pressed(weapon: WeaponInstance)

const PixelUI := preload("res://scripts/pixel_ui.gd")
const MARGIN := 14
const ICON_SCALE := 2
const DIM := Color(1, 1, 1, 0.45)

var _weapon: WeaponInstance


## weapon = null: leerer Platz. is_start: der Startwaffen-Platz (wird markiert).
func setup(weapon: WeaponInstance, is_start: bool) -> void:
	_weapon = weapon
	# Schlichter Rahmen statt des dicken Fensterrahmens, damit vier Karten in die Spalte passen
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.065, 0.15)
	style.set_border_width_all(3)
	style.border_color = Color("#a45b30")
	style.set_content_margin_all(MARGIN)
	add_theme_stylebox_override("panel", style)
	if weapon == null:
		_build_empty(is_start)
		return
	mouse_filter = Control.MOUSE_FILTER_STOP
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	var icon := TextureRect.new()
	icon.texture = weapon.data.icon
	icon.custom_minimum_size = Vector2(32, 32) * ICON_SCALE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 2)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text)
	# Zeile 1: Name links, rechts die Markierung der Startwaffe
	var head := HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_child(head)
	var name_label := _label(tr(weapon.data.name_key), PixelUI.SELECTED_TEXT_COLOR)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.clip_text = true
	head.add_child(name_label)
	if is_start:
		head.add_child(_label(tr("WEAPON_START_MARK"), PixelUI.SELECTED_TEXT_COLOR))
	# Zeile 2: Level-Leiste, Level und Entwicklungsstufe als Sterne
	var level_row := HBoxContainer.new()
	level_row.add_theme_constant_override("separation", 12)
	level_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_child(level_row)
	var bar := LevelBar.new()
	bar.level = weapon.level
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	level_row.add_child(bar)
	level_row.add_child(_label(tr("WEAPON_LEVEL_SHORT") % weapon.level, PixelUI.TEXT_COLOR))
	var stars := EvolutionStars.new()
	stars.stars = weapon.data.max_evolution
	stars.reached = weapon.evolution
	stars.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	level_row.add_child(stars)
	# Zeile 3: die wichtigsten Werte links, das Element rechts (in der Elementfarbe)
	var stats_row := HBoxContainer.new()
	stats_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_child(stats_row)
	var stats_label := _label(WeaponStatDisplay.compact_text(weapon, tr), PixelUI.TEXT_COLOR)
	stats_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_row.add_child(stats_label)
	stats_row.add_child(_label(Elements.display_name(weapon.data.element, tr), Elements.damage_color(weapon.data.element, false)))


func _build_empty(is_start: bool) -> void:
	modulate = DIM
	var label := _label(tr("WEAPON_SLOT_EMPTY_START") if is_start else tr("WEAPON_SLOT_EMPTY"), PixelUI.TEXT_COLOR)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(label)


func _label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _gui_input(event: InputEvent) -> void:
	if _weapon == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		pressed.emit(_weapon)
