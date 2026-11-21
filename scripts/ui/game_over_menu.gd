class_name GameOverMenu
extends Control
## Ende des Runs (Sieg oder Niederlage): hält das Spiel an, zeigt eine Zusammenfassung (Welle, Zeit, Kills, Stufe, Seelen,
## Waffen mit Stufe und Gesamtschaden) und führt zu einem neuen Run oder ins Hauptmenü.
## Seltener Bildschirm: Die Run-Szene setzt victory, boss_defeated, run_state und weapons vor dem Einhängen.

const PixelUI := preload("res://scripts/ui/pixel_ui.gd")
const VICTORY_COLOR := Color(1.0, 0.8, 0.35)
## Waffen-Symbole (32×32) werden 2× gezeichnet
const WEAPON_ICON_SIZE := Vector2(64.0, 64.0)
## Waffen je Reihe in der Zusammenfassung (4 = alle nebeneinander)
const WEAPON_COLUMNS := 4

## Sieg statt Niederlage und ob der Boss besiegt wurde (sonst: letzte Welle überlebt)
var victory := false
var boss_defeated := false
var run_state: RunState
var weapons: WeaponHolder

@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var title: Label = $Center/Content/Title
@onready var content: VBoxContainer = $Center/Content
@onready var buttons: HBoxContainer = $Center/Content/Buttons


func _ready() -> void:
	theme = PixelUI.make_theme()
	get_tree().paused = true
	if victory:
		title.text = "VICTORY_TITLE"
		title.add_theme_color_override("font_color", VICTORY_COLOR)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	if run_state:
		_build_summary()
	retry_button.pressed.connect(SceneRouter.start_run)
	main_menu_button.pressed.connect(SceneRouter.go_to_main_menu)


func _unhandled_input(event: InputEvent) -> void:
	# Esc bzw. Zurück-Geste öffnen hier nicht die Pause: Der Spieler entscheidet über die Knöpfe
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()


## Zusammenfassung zwischen Trennlinie und Knöpfen: eine Zeile, wie der Run endete, Werte in zwei Spalten, darunter die Waffen
func _build_summary() -> void:
	var index := buttons.get_index()
	var outcome := _label(_outcome_text(), PixelUI.TEXT_COLOR)
	outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(outcome)
	content.move_child(outcome, index)

	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 8)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if run_state.wave_total > 0:
		_stat(grid, "PAUSE_RUN_WAVE", "%d / %d" % [run_state.wave, run_state.wave_total])
	_stat(grid, "PAUSE_RUN_TIME", RestMenu._format_time(run_state.time))
	_stat(grid, "PAUSE_RUN_KILLS", format_number(run_state.kills))
	_stat(grid, "SUMMARY_LEVEL", str(run_state.level))
	_stat(grid, "SUMMARY_SOULS", format_number(run_state.souls_earned))
	_stat(grid, "SUMMARY_XP", format_number(run_state.xp_gained))
	content.add_child(grid)
	content.move_child(grid, index + 1)

	if weapons:
		var row := _weapon_row()
		content.add_child(row)
		content.move_child(row, index + 2)


func _outcome_text() -> String:
	if victory:
		return tr("SUMMARY_BOSS_DEFEATED" if boss_defeated else "SUMMARY_SURVIVED")
	if run_state.wave_total > 0:
		return tr("SUMMARY_FELL_IN_WAVE") % [run_state.wave, run_state.wave_total]
	return ""


## Waffen nebeneinander in einer Reihe (höchstens 4), die stärkste zuerst: Symbol, Name, Stufe und Gesamtschaden
func _weapon_row() -> GridContainer:
	var row := GridContainer.new()
	row.columns = WEAPON_COLUMNS
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("h_separation", 48)
	row.add_theme_constant_override("v_separation", 8)
	var list := weapons.all_weapons()
	list.sort_custom(func(a: WeaponInstance, b: WeaponInstance) -> bool: return a.total_damage > b.total_damage)
	for weapon in list:
		var box := HBoxContainer.new()
		box.add_theme_constant_override("separation", 12)
		var icon := TextureRect.new()
		icon.texture = weapon.data.icon
		icon.custom_minimum_size = WEAPON_ICON_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		box.add_child(icon)
		var texts := VBoxContainer.new()
		texts.add_theme_constant_override("separation", 0)
		texts.add_child(_label(tr(weapon.data.name_key), PixelUI.SELECTED_TEXT_COLOR))
		texts.add_child(_label(tr("SUMMARY_WEAPON_LINE") % [weapon.level, format_number(roundi(weapon.total_damage))], PixelUI.TEXT_COLOR))
		box.add_child(texts)
		row.add_child(box)
	return row


func _stat(grid: GridContainer, key: String, value: String) -> void:
	grid.add_child(_label(tr(key), PixelUI.TEXT_COLOR))
	grid.add_child(_label(value, PixelUI.SELECTED_TEXT_COLOR))


func _label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	return label


## Ganze Zahl mit Tausenderpunkten („12.345“)
static func format_number(value: int) -> String:
	var digits := str(absi(value))
	var result := ""
	while digits.length() > 3:
		result = "." + digits.substr(digits.length() - 3) + result
		digits = digits.substr(0, digits.length() - 3)
	return ("-" if value < 0 else "") + digits + result
