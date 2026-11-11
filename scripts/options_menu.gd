extends Control
## Optionsmenü: wird aus dem Hauptmenü und aus der Pause geöffnet und schließt sich selbst.
## Reiter und Zeilen entstehen aus scripts/options_catalog.gd, hier steht keine einzelne Option fest im Code.

signal closed

const PixelUI := preload("res://scripts/pixel_ui.gd")
## Größen der Elemente (der Inhaltsbereich selbst ist in options_menu.tscn festgelegt)
const ROW_FONT_SIZE := 32
const CHOICE_BUTTON_SIZE := Vector2(230.0, 88.0)
const TAB_BUTTON_SIZE := Vector2(260.0, 88.0)
const TAB_FONT_SIZE := 32
const SLIDER_WIDTH := 520.0
const SLIDER_HEIGHT := 88.0
const SLIDER_VALUE_WIDTH := 130.0

## Zuletzt geöffneter Reiter (bleibt gemerkt, solange die App läuft)
static var _last_category: StringName = &""

var _closing := false
var _options: Array[OptionDef] = []
## Aktualisiert die Anzeige der sichtbaren Zeilen nach einer Änderung (eine Funktion je Zeile)
var _refreshers: Array[Callable] = []

@onready var tabs: HBoxContainer = %Tabs
@onready var grid: GridContainer = %Grid
@onready var back_button: Button = %BackButton


func _ready() -> void:
	theme = PixelUI.make_theme()
	_options = OptionsCatalog.options()
	_build_tabs()
	back_button.pressed.connect(close)
	Settings.changed.connect(_refresh)


func close() -> void:
	if _closing:
		return
	_closing = true
	Settings.save_settings()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# Esc am PC bzw. Zurück-Geste am Handy (siehe BackGesture)
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


# ---------- Reiter ----------

func _build_tabs() -> void:
	var group := ButtonGroup.new()
	var first: StringName = &""
	var selected: Button
	for entry: Array in OptionsCatalog.CATEGORIES:
		var category_id: StringName = entry[0]
		if not _has_options(category_id):
			continue  # leere Kategorien ausblenden
		var button := _make_toggle_button(entry[1], TAB_BUTTON_SIZE, group)
		button.add_theme_font_size_override("font_size", TAB_FONT_SIZE)
		button.pressed.connect(_show_category.bind(category_id))
		tabs.add_child(button)
		if first.is_empty():
			first = category_id
			selected = button
		if category_id == _last_category:
			selected = button
	if selected == null:
		return
	selected.button_pressed = true
	_show_category(_last_category if _has_options(_last_category) else first)


func _has_options(category_id: StringName) -> bool:
	for option in _options:
		if option.category == category_id:
			return true
	return false


func _show_category(category_id: StringName) -> void:
	_last_category = category_id
	_refreshers.clear()
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	for option in _options:
		if option.category != category_id:
			continue
		var label := Label.new()
		label.text = option.label_key
		# Beschriftung füllt die linke Spalte, die Bedienelemente stehen dadurch rechts
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", ROW_FONT_SIZE)
		grid.add_child(label)
		match option.kind:
			OptionDef.Kind.TOGGLE:
				grid.add_child(_build_choices(option, [[true, "OPTIONS_ON"], [false, "OPTIONS_OFF"]]))
			OptionDef.Kind.CHOICE:
				grid.add_child(_build_choices(option, option.choices))
			OptionDef.Kind.SLIDER:
				grid.add_child(_build_slider(option))
	_refresh()


# ---------- Zeilen ----------

func _build_choices(option: OptionDef, values: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var group := ButtonGroup.new()
	var buttons: Array[Button] = []
	for entry: Array in values:
		var value: Variant = entry[0]
		var button := _make_toggle_button(entry[1], CHOICE_BUTTON_SIZE, group)
		button.add_theme_font_size_override("font_size", ROW_FONT_SIZE)
		button.pressed.connect(Settings.set_option.bind(option.setting, value))
		row.add_child(button)
		buttons.append(button)
	_refreshers.append(func() -> void:
		var current: Variant = Settings.get(option.setting)
		for i in buttons.size():
			var value: Variant = values[i][0]
			buttons[i].set_pressed_no_signal(value == current)
			buttons[i].disabled = option.is_choice_disabled.is_valid() and option.is_choice_disabled.call(value)
	)
	return row


func _build_slider(option: OptionDef) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 32)
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(SLIDER_WIDTH, SLIDER_HEIGHT)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.min_value = option.min_value
	slider.max_value = option.max_value
	slider.step = option.step
	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(SLIDER_VALUE_WIDTH, 0.0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", ROW_FONT_SIZE)
	row.add_child(slider)
	row.add_child(value_label)
	# Beim Ziehen nicht ständig speichern, erst beim Loslassen
	slider.value_changed.connect(func(value: float) -> void: Settings.set_option(option.setting, value, false))
	slider.drag_ended.connect(func(_changed: bool) -> void: Settings.save_settings())
	_refreshers.append(func() -> void:
		var current: float = Settings.get(option.setting)
		slider.set_value_no_signal(current)
		value_label.text = option.value_format % current
	)
	return row


func _make_toggle_button(text_key: String, min_size: Vector2, group: ButtonGroup) -> Button:
	var button := Button.new()
	button.text = text_key
	button.toggle_mode = true
	button.button_group = group
	button.custom_minimum_size = min_size
	return button


func _refresh() -> void:
	for refresher in _refreshers:
		refresher.call()
