class_name ChangelogMenu
extends Control
## „Neuigkeiten“ aus dem Hauptmenü: scrollbare Liste der Änderungen je Version (neueste oben).
## Der Inhalt steht in data/changelog/changelog_de.txt, damit für eine neue Version nur diese Datei ergänzt wird:
## „## Version · Datum“ beginnt eine Version, „- Text“ ist ein Punkt, Zeilen mit „#“ sind Notizen.
## Die Datei ist kein Godot-Resource-Typ und kommt über den Export-Filter „*.txt“ in die APK.
## Seltener Bildschirm: wird beim Öffnen gebaut und beim Schließen freigegeben.

signal closed

const PixelUI := preload("res://scripts/ui/pixel_ui.gd")
## Später je Sprache eine eigene Datei (changelog_en.txt, E15)
const CHANGELOG_PATH := "res://data/changelog/changelog_de.txt"
const DIM_COLOR := Color(0.03, 0.02, 0.06, 0.85)
const PANEL_SIZE := Vector2(1200.0, 760.0)

## Inhaltsliste (für Tests)
var entries: VBoxContainer


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
	var panel := PanelContainer.new()
	panel.custom_minimum_size = PANEL_SIZE
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 48)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 32)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	margin.add_child(box)
	var title := Label.new()
	title.text = "MENU_NEWS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_TITLE)
	title.add_theme_color_override("font_color", PixelUI.SELECTED_TEXT_COLOR)
	box.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	entries = VBoxContainer.new()
	entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entries.add_theme_constant_override("separation", 8)
	scroll.add_child(entries)
	_fill(_read_lines())
	var back := Button.new()
	back.text = "BUTTON_BACK"
	back.custom_minimum_size = Vector2(360.0, 96.0)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(_close)
	box.add_child(back)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _read_lines() -> PackedStringArray:
	if not FileAccess.file_exists(CHANGELOG_PATH):
		return PackedStringArray()
	return FileAccess.get_file_as_string(CHANGELOG_PATH).split("\n")


## Baut aus den Zeilen Versions-Überschriften und Punkte
func _fill(lines: PackedStringArray) -> void:
	var first := true
	for raw in lines:
		var line := raw.strip_edges()
		if line.begins_with("## "):
			var header := _label(line.substr(3), PixelUI.SELECTED_TEXT_COLOR)
			header.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_HEADER)
			if not first:
				var gap := Control.new()
				gap.custom_minimum_size = Vector2(0.0, 24.0)
				entries.add_child(gap)
			first = false
			entries.add_child(header)
		elif line.begins_with("- "):
			entries.add_child(_label("•  " + line.substr(2), PixelUI.TEXT_COLOR))
	if entries.get_child_count() == 0:
		entries.add_child(_label(tr("NEWS_EMPTY"), PixelUI.TEXT_COLOR))


func _label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", color)
	# Texte aus der Datei sind schon fertig, nicht übersetzen
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	return label


func _close() -> void:
	closed.emit()
	queue_free()
