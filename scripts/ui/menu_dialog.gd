class_name MenuDialog
extends Control
## Kleines Fenster über einem Menü: Nachfrage (Text, Ja/Nein) oder Namenseingabe (Textfeld, Ok/Abbrechen).
## Abdunkelt den Hintergrund und fängt alle Berührungen ab. Zurück-Geste bzw. Esc = Abbrechen.
## Die Namenseingabe sitzt im oberen Bildschirmteil, damit die Handy-Tastatur sie nicht verdeckt.

## Ja / Ok gedrückt (text: eingegebener Name, sonst leer)
signal confirmed(text: String)
signal cancelled

const PixelUI := preload("res://scripts/ui/pixel_ui.gd")
const DIM_COLOR := Color(0.03, 0.02, 0.06, 0.8)
const BUTTON_SIZE := Vector2(360.0, 96.0)
## Abstand der Namenseingabe vom oberen Rand (darunter liegt die Bildschirmtastatur)
const INPUT_TOP := 120.0

var _input: LineEdit
var _yes: Button
## Muss exakt eingetippt werden, damit „Ja“ aktiv wird (leer = keine Bedingung)
var _required := ""
var _done := false


## Nachfrage mit zwei Knöpfen
static func ask(question: String, yes_key: String, no_key: String) -> MenuDialog:
	var dialog := MenuDialog.new()
	dialog._build(question, yes_key, no_key, false, "")
	return dialog


## Sicherheitsabfrage: „Ja“ wird erst aktiv, wenn required genau eingetippt ist (Groß-/Kleinschreibung egal)
static func ask_typed(question: String, required: String, yes_key: String, no_key: String) -> MenuDialog:
	var dialog := MenuDialog.new()
	dialog._required = required.strip_edges()
	dialog._build(question, yes_key, no_key, true, "")
	dialog._input.placeholder_text = dialog._required
	dialog._input.text_changed.connect(dialog._on_text_changed)
	dialog._on_text_changed("")
	return dialog


## Namenseingabe mit Vorschlag
static func ask_name(question: String, suggestion: String, ok_key: String, cancel_key: String) -> MenuDialog:
	var dialog := MenuDialog.new()
	dialog._build(question, ok_key, cancel_key, true, suggestion)
	return dialog


func _build(question: String, yes_key: String, no_key: String, with_input: bool, suggestion: String) -> void:
	theme = PixelUI.make_theme()
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = DIM_COLOR
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var holder: Container
	if with_input:
		# Oben mittig statt in der Bildmitte (Tastatur)
		var top := VBoxContainer.new()
		top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		top.offset_top = INPUT_TOP
		top.alignment = BoxContainer.ALIGNMENT_BEGIN
		top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var row := CenterContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top.add_child(row)
		add_child(top)
		holder = row
	else:
		var center := CenterContainer.new()
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(center)
		holder = center
	var panel := PanelContainer.new()
	holder.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 48)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 36)
	margin.add_child(box)
	var label := Label.new()
	label.text = question
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)
	if with_input:
		_input = LineEdit.new()
		_input.text = suggestion
		_input.max_length = SaveSlots.NAME_MAX_LENGTH
		_input.custom_minimum_size = Vector2(640.0, 88.0)
		_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
		_input.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_BUTTON)
		_input.select_all_on_focus = true
		_input.text_submitted.connect(func(_t: String) -> void: _on_yes())
		box.add_child(_input)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 32)
	box.add_child(buttons)
	_yes = Button.new()
	_yes.text = yes_key
	_yes.custom_minimum_size = BUTTON_SIZE
	_yes.pressed.connect(_on_yes)
	buttons.add_child(_yes)
	var no := Button.new()
	no.text = no_key
	no.custom_minimum_size = BUTTON_SIZE
	no.pressed.connect(_on_no)
	buttons.add_child(no)


func _ready() -> void:
	if _input:
		_input.grab_focus.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_no()


func _on_text_changed(text: String) -> void:
	_yes.disabled = not _matches(text)


func _matches(text: String) -> bool:
	return _required.is_empty() or text.strip_edges().to_lower() == _required.to_lower()


func _on_yes() -> void:
	if _done or (_input and not _matches(_input.text)):
		return
	_done = true
	confirmed.emit(_input.text if _input else "")
	queue_free()


func _on_no() -> void:
	if _done:
		return
	_done = true
	cancelled.emit()
	queue_free()
