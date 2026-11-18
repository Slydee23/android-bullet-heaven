class_name WeaponDetail
extends Control
## Detailfenster einer Waffe (öffnet sich über der Waffenkarte): Fähigkeit, Rang, alle Werte, gewählte Upgrades,
## Entwicklung und bisher verursachter Schaden. Schließt mit Zurück, Esc oder der Zurück-Geste.

signal closed

const PixelUI := preload("res://scripts/pixel_ui.gd")

var weapon: WeaponInstance


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.02, 0.01, 0.04, 0.85)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1200, 0)
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)

	# Kopf: Icon, Name, Element, Level
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 24)
	column.add_child(head)
	var icon := TextureRect.new()
	icon.texture = weapon.data.icon
	icon.custom_minimum_size = Vector2(32, 32) * 4
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	head.add_child(icon)
	var title := VBoxContainer.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	title.add_child(_label(tr(weapon.data.name_key), PixelUI.FONT_SIZE_HEADER, PixelUI.SELECTED_TEXT_COLOR))
	title.add_child(_label(Elements.display_name(weapon.data.element, tr), PixelUI.FONT_SIZE_SMALL, Elements.damage_color(weapon.data.element, false)))
	var level_row := HBoxContainer.new()
	level_row.add_theme_constant_override("separation", 32)
	title.add_child(level_row)
	var bar := LevelBar.new()
	bar.level = weapon.level
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	level_row.add_child(bar)
	level_row.add_child(_label(tr("WEAPON_LEVEL_LONG") % [weapon.level, LevelBar.MAX_LEVEL], PixelUI.FONT_SIZE_SMALL, PixelUI.TEXT_COLOR))
	level_row.add_child(_label(tr("WEAPON_EVOLUTION_LABEL"),PixelUI.FONT_SIZE_SMALL, PixelUI.TEXT_COLOR))
	var stars := EvolutionStars.new()
	stars.stars = weapon.data.max_evolution
	stars.reached = weapon.evolution
	stars.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	level_row.add_child(stars)

	column.add_child(_label(tr(weapon.data.description_key), PixelUI.FONT_SIZE_SMALL, PixelUI.TEXT_COLOR, true))

	# Werte
	column.add_child(_label(tr("WEAPON_SECTION_STATS"), PixelUI.FONT_SIZE_SMALL, PixelUI.SELECTED_TEXT_COLOR))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 4)
	column.add_child(grid)
	for row: Array in WeaponStatDisplay.detail_rows(weapon, tr):
		var name_cell := _label(row[0], PixelUI.FONT_SIZE_SMALL, PixelUI.TEXT_COLOR)
		name_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(name_cell)
		var value_cell := _label(row[1], PixelUI.FONT_SIZE_SMALL, PixelUI.SELECTED_TEXT_COLOR)
		value_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(value_cell)

	# Gewählte Upgrades: je Upgrade die Summe aller Wahlen und wie oft („Schaden +25 (2×)“), Reihenfolge wie im Pool der Waffe
	column.add_child(_label(tr("WEAPON_SECTION_UPGRADES"), PixelUI.FONT_SIZE_SMALL, PixelUI.SELECTED_TEXT_COLOR))
	var upgrade_grid := GridContainer.new()
	upgrade_grid.columns = 4
	upgrade_grid.add_theme_constant_override("h_separation", 24)
	upgrade_grid.add_theme_constant_override("v_separation", 4)
	for upgrade in weapon.data.upgrades:
		var count := weapon.upgrade_count(upgrade.id)
		if count == 0:
			continue
		# Abklingzeit-Upgrades heißen hier „Abklingzeit −8 %“ (als „Angriffe pro Sekunde −8 %“ läse es sich wie eine Verschlechterung)
		var key := "STAT_COOLDOWN" if upgrade.stat == &"cooldown" else WeaponStatDisplay.label_key(weapon, upgrade.stat)
		var name_cell := _label(tr(key), PixelUI.FONT_SIZE_SMALL, PixelUI.TEXT_COLOR)
		name_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		upgrade_grid.add_child(name_cell)
		var amount := upgrade.format_amount(weapon.upgrade_totals.get(upgrade.id, 0.0))
		var value_cell := _label(tr("WEAPON_UPGRADE_TOTAL") % [amount, count], PixelUI.FONT_SIZE_SMALL, PixelUI.SELECTED_TEXT_COLOR)
		value_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		upgrade_grid.add_child(value_cell)
	if upgrade_grid.get_child_count() > 0:
		column.add_child(upgrade_grid)
	else:
		upgrade_grid.free()
		column.add_child(_label(tr("WEAPON_NO_UPGRADES"), PixelUI.FONT_SIZE_SMALL, PixelUI.TEXT_COLOR))
	column.add_child(_label(tr("WEAPON_SECTION_EVOLUTION"), PixelUI.FONT_SIZE_SMALL, PixelUI.SELECTED_TEXT_COLOR))
	column.add_child(_label(tr("WEAPON_NO_EVOLUTION"), PixelUI.FONT_SIZE_SMALL, PixelUI.TEXT_COLOR))
	column.add_child(_label(tr("WEAPON_DAMAGE_DEALT") % roundi(weapon.total_damage), PixelUI.FONT_SIZE_SMALL, PixelUI.TEXT_COLOR))

	var back := Button.new()
	back.text = "BUTTON_BACK"
	back.custom_minimum_size = Vector2(320, 96)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(close)
	column.add_child(back)


func close() -> void:
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _label(text: String, font_size: int, color: Color, wrap := false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
