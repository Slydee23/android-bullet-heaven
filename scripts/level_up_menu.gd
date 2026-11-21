class_name LevelUpMenu
extends Control
## Level-Up-Fenster: Das Spiel steht, 3 Karten nebeneinander, eine antippen. Seltener Bildschirm: wird beim Öffnen gebaut
## und beim Schließen freigegeben. Die Run-Szene setzt offers und level vor dem Einhängen und wendet die Wahl an.

## Eine Karte wurde gewählt
signal chosen(offer: LevelUpOffer)
## Neu würfeln gedrückt: Die Run-Szene würfelt neu und ruft set_offers auf
signal reroll_requested
## Überspringen gedrückt: keine Karte, das Level-Up ist verbraucht
signal skipped

const PixelUI := preload("res://scripts/pixel_ui.gd")
## So lange sind die Karten nach dem Öffnen gesperrt, damit ein Daumen, der gerade noch steuert, nicht versehentlich wählt
const INPUT_DELAY := 0.5
const DIM_COLOR := Color(0.03, 0.02, 0.06, 0.72)

var offers: Array[LevelUpOffer] = []
## Erreichte Stufe (für die Überschrift)
var level := 1
## Übrige Neu-Würfeln-Versuche (0 = Knopf gesperrt)
var rerolls := 0

var _cards: Array[LevelUpCard] = []
var _row: HBoxContainer
var _reroll_button: Button
var _skip_button: Button
var _done := false
var _armed := false


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
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 32)
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_row)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 32)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(buttons)
	_reroll_button = Button.new()
	_reroll_button.custom_minimum_size = Vector2(420.0, 80.0)
	_reroll_button.disabled = true
	_reroll_button.pressed.connect(_on_reroll_pressed)
	buttons.add_child(_reroll_button)
	_skip_button = Button.new()
	_skip_button.text = tr("LEVEL_UP_SKIP")
	_skip_button.custom_minimum_size = Vector2(420.0, 80.0)
	_skip_button.disabled = true
	_skip_button.pressed.connect(_on_skip_pressed)
	buttons.add_child(_skip_button)
	set_offers(offers)
	# Timer läuft auch bei angehaltenem Spiel
	get_tree().create_timer(INPUT_DELAY, true).timeout.connect(_enable_cards)


## Zeigt neue Karten (nach dem Neu-Würfeln) und aktualisiert den Würfel-Knopf
func set_offers(new_offers: Array[LevelUpOffer]) -> void:
	offers = new_offers
	for card in _cards:
		_row.remove_child(card)
		card.queue_free()
	_cards.clear()
	for offer in offers:
		var card := LevelUpCard.new()
		_row.add_child(card)
		card.setup(offer)
		card.disabled = not _armed
		card.pressed.connect(_on_card_pressed.bind(offer))
		_cards.append(card)
	_reroll_button.text = tr("LEVEL_UP_REROLL") % rerolls
	_reroll_button.disabled = not _armed or rerolls <= 0


func _enable_cards() -> void:
	_armed = true
	for card in _cards:
		card.disabled = false
	_skip_button.disabled = false
	_reroll_button.disabled = rerolls <= 0


func _on_reroll_pressed() -> void:
	if _done or not _armed or rerolls <= 0:
		return
	reroll_requested.emit()


func _on_skip_pressed() -> void:
	if _done or not _armed:
		return
	_done = true
	skipped.emit()


func _on_card_pressed(offer: LevelUpOffer) -> void:
	if _done:
		return
	_done = true
	chosen.emit(offer)
