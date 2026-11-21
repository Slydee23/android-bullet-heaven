extends Control
## Hauptmenü: Fortsetzen (wenn es einen Spielstand gibt), Neues Spiel und Optionen.
## Fortsetzen und Neues Spiel öffnen beide die Speicherplätze (SlotMenu).

const PixelUI := preload("res://scripts/ui/pixel_ui.gd")

const OPTIONS_MENU := preload("res://ui/options_menu.tscn")

@onready var start_button: Button = %StartButton
@onready var options_button: Button = %OptionsButton
@onready var version_label: Label = %VersionLabel
## Titel und Knöpfe (ausgeblendet, solange die Speicherplätze offen sind; der Hintergrund bleibt)
@onready var menu_center: Control = $Center

## Nur sichtbar, wenn mindestens ein Spielstand existiert
var continue_button: Button
## Offenes Speicherplatz-Menü (oder null)
var slot_menu: SlotMenu


func _ready() -> void:
	theme = PixelUI.make_theme()
	# Version steht zentral in Projekteinstellungen → Anwendung → Konfiguration → Version
	version_label.text = ProjectSettings.get_setting("application/config/version", "")
	SaveSlots.migrate_legacy()

	continue_button = Button.new()
	continue_button.text = "MENU_CONTINUE"
	continue_button.custom_minimum_size = start_button.custom_minimum_size
	continue_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	continue_button.pressed.connect(_open_slots.bind(SlotMenu.Mode.LOAD))
	start_button.get_parent().add_child(continue_button)
	start_button.get_parent().move_child(continue_button, start_button.get_index())
	_update_continue()

	start_button.pressed.connect(_open_slots.bind(SlotMenu.Mode.NEW))
	options_button.pressed.connect(_on_options_button_pressed)


func _update_continue() -> void:
	continue_button.visible = SaveSlots.any_exists()


func _open_slots(mode: SlotMenu.Mode) -> void:
	if slot_menu:
		return
	slot_menu = SlotMenu.new()
	slot_menu.mode = mode
	slot_menu.slots_changed.connect(_update_continue)
	slot_menu.closed.connect(_on_slots_closed)
	add_child(slot_menu)
	menu_center.visible = false


func _on_slots_closed() -> void:
	slot_menu = null
	menu_center.visible = true
	_update_continue()


func _on_options_button_pressed() -> void:
	add_child(OPTIONS_MENU.instantiate())
