class_name LevelUpMenu
extends Control
## Level-Up-Fenster: Das Spiel steht, 3 Karten nebeneinander, eine antippen. Seltener Bildschirm: wird beim Öffnen gebaut
## und beim Schließen freigegeben. Die Run-Szene setzt offers und level vor dem Einhängen und wendet die Wahl an.

## Eine Karte wurde gewählt
signal chosen(offer: LevelUpOffer)

const PixelUI := preload("res://scripts/pixel_ui.gd")
## So lange sind die Karten nach dem Öffnen gesperrt, damit ein Daumen, der gerade noch steuert, nicht versehentlich wählt
const INPUT_DELAY := 0.5
const DIM_COLOR := Color(0.03, 0.02, 0.06, 0.72)

var offers: Array[LevelUpOffer] = []
## Erreichte Stufe (für die Überschrift)
var level := 1

var _cards: Array[LevelUpCard] = []
var _done := false


func _ready() -> void:
	theme = PixelUI.make_theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = DIM_COLOR
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 32)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(box)
	var title := Label.new()
	title.text = tr("LEVEL_UP_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_TITLE)
	title.add_theme_color_override("font_color", PixelUI.SELECTED_TEXT_COLOR)
	box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = tr("LEVEL_UP_SUBTITLE") % level
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 32)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	for offer in offers:
		var card := LevelUpCard.new()
		row.add_child(card)
		card.setup(offer)
		card.disabled = true
		card.pressed.connect(_on_card_pressed.bind(offer))
		_cards.append(card)
	# Timer läuft auch bei angehaltenem Spiel
	get_tree().create_timer(INPUT_DELAY, true).timeout.connect(_enable_cards)


func _enable_cards() -> void:
	for card in _cards:
		card.disabled = false


func _on_card_pressed(offer: LevelUpOffer) -> void:
	if _done:
		return
	_done = true
	chosen.emit(offer)
