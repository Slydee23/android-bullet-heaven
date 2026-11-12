class_name PauseMenu
extends Control
## Pause-/Statusbildschirm: hält das Spiel an, zeigt den Run-Status (ab M3) und führt zu Optionen oder zurück ins Hauptmenü.

signal closed

const PixelUI := preload("res://scripts/pixel_ui.gd")
const OPTIONS_MENU := preload("res://ui/options_menu.tscn")

## Held, dessen Werte angezeigt werden (setzt die Run-Szene vor dem Öffnen)
var player: Player
## Waffen des Helden für die Waffenspalte (setzt die Run-Szene vor dem Öffnen)
var weapon_holder: WeaponHolder

## Zweites Antippen von „Run aufgeben“ bestätigt (schützt vor versehentlichem Aufgeben)
var _abandon_armed := false

@onready var hp_label: Label = %HpLabel
@onready var weapons_column: PanelContainer = %WeaponsColumn
@onready var weapon_list: VBoxContainer = %WeaponList
@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var abandon_button: Button = %AbandonButton


func _ready() -> void:
	theme = PixelUI.make_theme()
	get_tree().paused = true
	if player:
		hp_label.text = tr("PAUSE_HP") % [ceili(player.hp), roundi(player.max_hp)]
	_build_weapons()
	resume_button.pressed.connect(close)
	options_button.pressed.connect(_on_options_pressed)
	abandon_button.pressed.connect(_on_abandon_pressed)


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
