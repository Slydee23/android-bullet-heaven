class_name SlotMenu
extends Control
## Die drei Speicherplätze (SaveSlots) nebeneinander. Zwei Arten:
## - LOAD („Fortsetzen“): belegten Platz antippen → laufende Expedition fortsetzen bzw. neue Expedition in diesem Spielstand.
## - NEW („Neues Spiel“): leeren Platz antippen → Namen eingeben → Spiel beginnt; belegter Platz → erst „Überschreiben?“.
## Jeder Platz zeigt Name, zuletzt gespielt und (vorläufig, bis es Meta-Fortschritt gibt) die laufende Expedition, darunter „Löschen“.
## Seltener Bildschirm: wird beim Öffnen gebaut und beim Schließen freigegeben.

## Menü geschlossen (Zurück) oder ein Platz wurde gelöscht: Das Hauptmenü aktualisiert „Fortsetzen“
signal closed
signal slots_changed

enum Mode { LOAD, NEW }

const PixelUI := preload("res://scripts/ui/pixel_ui.gd")
const DIM_COLOR := Color(0.03, 0.02, 0.06, 0.6)
const CARD_SIZE := Vector2(520.0, 300.0)
const DELETE_SIZE := Vector2(520.0, 80.0)
const EMPTY_COLOR := Color(0.6, 0.56, 0.66)

var mode := Mode.LOAD

var _row: HBoxContainer
## Platz-Knöpfe (für Tests)
var cards: Array[Button] = []
var delete_buttons: Array[Button] = []


func _ready() -> void:
	theme = PixelUI.make_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = DIM_COLOR
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 40)
	center.add_child(box)
	var title := Label.new()
	title.text = "SLOTS_TITLE_LOAD" if mode == Mode.LOAD else "SLOTS_TITLE_NEW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_TITLE)
	title.add_theme_color_override("font_color", PixelUI.SELECTED_TEXT_COLOR)
	box.add_child(title)
	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.add_theme_constant_override("separation", 32)
	box.add_child(_row)
	var back := Button.new()
	back.text = "BUTTON_BACK"
	back.custom_minimum_size = Vector2(360.0, 96.0)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(_close)
	box.add_child(back)
	_rebuild()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _rebuild() -> void:
	for child in _row.get_children():
		_row.remove_child(child)
		child.queue_free()
	cards.clear()
	delete_buttons.clear()
	for i in SaveSlots.COUNT:
		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 12)
		_row.add_child(column)
		var card := _make_card(i)
		column.add_child(card)
		cards.append(card)
		var delete := Button.new()
		delete.text = "SLOT_DELETE"
		delete.custom_minimum_size = DELETE_SIZE
		delete.pressed.connect(_on_delete_pressed.bind(i))
		# Platzhalter bei leeren Plätzen, damit alle Karten gleich hoch bleiben
		delete.modulate.a = 1.0 if SaveSlots.exists(i) else 0.0
		delete.disabled = not SaveSlots.exists(i)
		column.add_child(delete)
		delete_buttons.append(delete)


func _make_card(index: int) -> Button:
	var card := Button.new()
	card.custom_minimum_size = CARD_SIZE
	card.focus_mode = Control.FOCUS_NONE
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 32)
	card.add_child(margin)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	var meta := SaveSlots.read_meta(index)
	if meta.is_empty():
		box.add_child(_label(tr("SLOT_EMPTY") % (index + 1), EMPTY_COLOR, PixelUI.FONT_SIZE_BUTTON))
		card.disabled = mode == Mode.LOAD
	else:
		box.add_child(_label(str(meta.get("name", "")), PixelUI.SELECTED_TEXT_COLOR, PixelUI.FONT_SIZE_BUTTON))
		box.add_child(_label(tr("SLOT_LAST_PLAYED") % SaveSlots.format_time(float(meta.get("last_played", 0))), PixelUI.TEXT_COLOR, PixelUI.FONT_SIZE_SMALL))
		# Vorläufig: laufende Expedition. Später zeigt der Platz hier den Meta-Fortschritt (Dorf, Freischaltungen …).
		box.add_child(_label(_run_text(index), PixelUI.TEXT_COLOR, PixelUI.FONT_SIZE_SMALL))
	card.pressed.connect(_on_card_pressed.bind(index))
	return card


func _run_text(index: int) -> String:
	var saved := RunSave.read_slot(index)
	if saved.is_empty():
		return tr("SLOT_NO_RUN")
	var level := int(saved.get("run", {}).get("level", 1))
	var wave := int(saved.get("wave", 1))
	if saved.get("phase", "") == RunSave.PHASE_REST:
		return tr("MENU_CONTINUE_REST") % [wave, level]
	return tr("MENU_CONTINUE_INFO") % [wave, int(saved.get("wave_total", 20)), level]


func _label(text: String, color: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _on_card_pressed(index: int) -> void:
	var used := SaveSlots.exists(index)
	if mode == Mode.LOAD:
		if used:
			_play(index)
		return
	if used:
		var slot_name := str(SaveSlots.read_meta(index).get("name", ""))
		var dialog := MenuDialog.ask(tr("SLOT_OVERWRITE_CONFIRM") % slot_name, "SLOT_OVERWRITE_YES", "MENU_NEW_RUN_NO")
		dialog.confirmed.connect(func(_t: String) -> void: _ask_name(index))
		add_child(dialog)
	else:
		_ask_name(index)


func _ask_name(index: int) -> void:
	var dialog := MenuDialog.ask_name(tr("SLOT_NAME_TITLE"), SaveSlots.default_name(index), "SLOT_START", "MENU_NEW_RUN_NO")
	dialog.confirmed.connect(_on_name_confirmed.bind(index))
	add_child(dialog)


func _on_name_confirmed(slot_name: String, index: int) -> void:
	SaveSlots.create(index, slot_name)
	SceneRouter.start_run()


## Spielstand laden: laufende Expedition fortsetzen, sonst eine neue Expedition in diesem Spielstand beginnen
## (später: ins Dorf)
func _play(index: int) -> void:
	SaveSlots.current = index
	if RunSave.exists():
		SceneRouter.continue_run()
	else:
		SceneRouter.start_run()


func _on_delete_pressed(index: int) -> void:
	if not SaveSlots.exists(index):
		return
	var slot_name := str(SaveSlots.read_meta(index).get("name", ""))
	# Sicherheitsabfrage: Der Name des Helden muss eingetippt werden
	var dialog := MenuDialog.ask_typed(tr("SLOT_DELETE_CONFIRM") % slot_name, slot_name, "SLOT_DELETE", "MENU_NEW_RUN_NO")
	dialog.confirmed.connect(func(_t: String) -> void: _delete(index))
	add_child(dialog)


func _delete(index: int) -> void:
	SaveSlots.delete(index)
	slots_changed.emit()
	if mode == Mode.LOAD and not SaveSlots.any_exists():
		_close()
		return
	_rebuild()


func _close() -> void:
	closed.emit()
	queue_free()
