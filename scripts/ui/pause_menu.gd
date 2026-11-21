class_name PauseMenu
extends Control
## Pause-/Statusbildschirm: hält das Spiel an, zeigt den Run-Status (ab M3) und führt zu Optionen oder zurück ins Hauptmenü.

signal closed

const PixelUI := preload("res://scripts/ui/pixel_ui.gd")
const OPTIONS_MENU := preload("res://ui/options_menu.tscn")
const HERO_UPGRADES := preload("res://data/upgrades/hero_upgrades.tres")
const XP_FILL := preload("res://assets/ui/hud_fill_xp.png")
## Runen-Siegel der Helden-Boni (32×32) in der Charakterspalte 1,5× gezeichnet
const BOON_ICON_SIZE := Vector2(48.0, 48.0)

## Held, dessen Werte angezeigt werden (setzt die Run-Szene vor dem Öffnen)
var player: Player
## Waffen des Helden für die Waffenspalte (setzt die Run-Szene vor dem Öffnen)
var weapon_holder: WeaponHolder
## Stufe, Erfahrung und globale Boni für die Charakterspalte (setzt die Run-Szene vor dem Öffnen)
var run_state: RunState

## Zweites Antippen von „Run aufgeben“ bestätigt (schützt vor versehentlichem Aufgeben)
var _abandon_armed := false

@onready var hp_label: Label = %HpLabel
@onready var run_placeholder: Label = %Placeholder
@onready var weapons_column: PanelContainer = %WeaponsColumn
@onready var weapon_list: VBoxContainer = %WeaponList
@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var abandon_button: Button = %AbandonButton


func _ready() -> void:
	theme = PixelUI.make_theme()
	get_tree().paused = true
	_build_character()
	_build_run_info()
	_build_weapons()
	resume_button.pressed.connect(close)
	options_button.pressed.connect(_on_options_pressed)
	abandon_button.pressed.connect(_on_abandon_pressed)


## Charakterspalte: Stufe mit XP-Leiste, Heldenwerte (inklusive der globalen Boni für alle Waffen) und gewählte Helden-Boni.
## Werte wie Krit, Rüstung oder Glück kommen dazu, sobald es sie gibt.
func _build_character() -> void:
	var content := hp_label.get_parent()
	if not player or not run_state:
		hp_label.text = ""
		return
	# Stufe und XP in einer Zeile, darunter die XP-Leiste (kompakt: die Spalte darf das Pausemenü nicht über den Bildschirm schieben)
	hp_label.text = tr("PAUSE_LEVEL") % run_state.level
	hp_label.add_theme_color_override("font_color", PixelUI.SELECTED_TEXT_COLOR)
	hp_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	var level_row := HBoxContainer.new()
	content.add_child(level_row)
	hp_label.reparent(level_row)
	hp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_row.add_child(_label(tr("PAUSE_XP") % [run_state.xp, run_state.xp_needed()], PixelUI.TEXT_COLOR, false))
	content.move_child(level_row, 1)
	var xp_bar := HudBar.new()
	xp_bar.fill_texture = XP_FILL
	xp_bar.custom_minimum_size = Vector2(0, 40)
	xp_bar.ratio = run_state.xp / float(maxi(run_state.xp_needed(), 1))
	content.add_child(xp_bar)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 4)
	content.add_child(grid)
	_stat_row(grid, tr("STAT_HP"), "%d / %d" % [ceili(player.hp), roundi(player.max_hp)])
	_stat_row(grid, tr("STAT_MOVE_SPEED"), str(roundi(player.speed)))
	_stat_row(grid, tr("STAT_PICKUP_RADIUS"), str(roundi(player.pickup_radius)))
	_stat_row(grid, tr("STAT_ALL_DAMAGE"), _percent_text(_global_sums(&"damage")[1]))
	_stat_row(grid, tr("STAT_ALL_COOLDOWN"), _percent_text(_global_sums(&"cooldown")[1]))
	var extra := roundi(_global_sums(&"amount")[0])
	_stat_row(grid, tr("STAT_ALL_AMOUNT"), "+%d" % extra if extra > 0 else "–")

	# Helden-Boni als Runen-Siegel in einer Reihe, darunter wie oft gewählt (alle sechs passen nebeneinander)
	content.add_child(_label(tr("PAUSE_SECTION_BOONS"), PixelUI.SELECTED_TEXT_COLOR))
	var boons := HFlowContainer.new()
	boons.add_theme_constant_override("h_separation", 8)
	for upgrade in HERO_UPGRADES.upgrades:
		var count := run_state.hero_upgrade_count(upgrade.id)
		if count == 0:
			continue
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 0)
		var icon := TextureRect.new()
		icon.texture = upgrade.icon
		icon.custom_minimum_size = BOON_ICON_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.tooltip_text = tr(upgrade.name_key)
		cell.add_child(icon)
		var amount := _label("×%d" % count, PixelUI.TEXT_COLOR, false)
		amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(amount)
		boons.add_child(cell)
	if boons.get_child_count() > 0:
		content.add_child(boons)
	else:
		boons.free()
		content.add_child(_label(tr("PAUSE_NO_BOONS"), PixelUI.TEXT_COLOR))


## Spalte „Ausrüstung & Run“: Welle, Kampfzeit und besiegte Gegner (Rüstung, Artefakte und Ausbeute kommen später)
func _build_run_info() -> void:
	if not run_state:
		return
	var content := run_placeholder.get_parent()
	run_placeholder.queue_free()
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 4)
	content.add_child(grid)
	_stat_row(grid, tr("PAUSE_RUN_WAVE"), "%d / %d" % [run_state.wave, run_state.wave_total])
	_stat_row(grid, tr("PAUSE_RUN_TIME"), RestMenu._format_time(run_state.time))
	_stat_row(grid, tr("PAUSE_RUN_KILLS"), str(run_state.kills))
	_stat_row(grid, tr("PAUSE_RUN_SOULS"), str(run_state.souls))


## Summen der globalen Boni des Helden für einen Stat: [Σ FLAT, Σ PERCENT, Π MULT]
func _global_sums(stat: StringName) -> PackedFloat32Array:
	var sums := StatBlock.new_sums()
	run_state.stats.accumulate(stat, sums)
	return sums


func _percent_text(share: float) -> String:
	var percent := roundi(share * 100.0)
	if percent == 0:
		return "–"
	return ("+%d %%" if percent > 0 else "−%d %%") % absi(percent)


func _stat_row(grid: GridContainer, title: String, value: String) -> void:
	var name_cell := _label(title, PixelUI.TEXT_COLOR)
	name_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(name_cell)
	grid.add_child(_label(value, PixelUI.SELECTED_TEXT_COLOR, false))


## Beschriftung im Pixel-Stil. wrap_text = false für Werte in Tabellen: Sonst würde die Wertspalte auf null Breite schrumpfen
## und jeden Buchstaben einzeln umbrechen.
func _label(text: String, color: Color, wrap_text := true) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	if wrap_text:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


## Eine Karte je Waffenplatz: zuerst der Startwaffen-Platz, dann die Run-Plätze. Antippen öffnet das Detailfenster.
func _build_weapons() -> void:
	var panel := weapons_column.get_theme_stylebox("panel", "PanelContainer").duplicate() as StyleBox
	panel.set_content_margin_all(24)
	panel.set_content_margin(SIDE_LEFT, 40.0)
	panel.set_content_margin(SIDE_RIGHT, 40.0)
	weapons_column.add_theme_stylebox_override("panel", panel)
	if not weapon_holder:
		return
	for slot in WeaponHolder.START_SLOTS:
		_add_weapon_card(weapon_holder.start_weapons[slot] if slot < weapon_holder.start_weapons.size() else null, true)
	for slot in WeaponHolder.RUN_SLOTS:
		_add_weapon_card(weapon_holder.run_weapons[slot] if slot < weapon_holder.run_weapons.size() else null, false)


func _add_weapon_card(weapon: WeaponInstance, is_start: bool) -> void:
	var card := WeaponCard.new()
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	weapon_list.add_child(card)
	card.setup(weapon, is_start)
	card.pressed.connect(_on_weapon_pressed)


func _on_weapon_pressed(weapon: WeaponInstance) -> void:
	var detail := WeaponDetail.new()
	detail.weapon = weapon
	add_child(detail)


func close() -> void:
	get_tree().paused = false
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# Esc am PC bzw. Zurück-Geste am Handy: weiterspielen
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _on_options_pressed() -> void:
	add_child(OPTIONS_MENU.instantiate())


func _on_abandon_pressed() -> void:
	if not _abandon_armed:
		_abandon_armed = true
		abandon_button.text = "PAUSE_ABANDON_CONFIRM"
		return
	# Bis M8 geht der Run dabei verloren
	SceneRouter.go_to_main_menu()
