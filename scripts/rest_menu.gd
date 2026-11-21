class_name RestMenu
extends Control
## Rastplatz zwischen den Wellen: Das Spiel steht. Oben eine kurze Zusammenfassung der überstandenen Welle, dann der Seelen-Shop
## (4 Stat-Karten zum Kaufen, Neu würfeln), unten „Weiter“ mit der Vorschau auf die nächste Welle. Später kommen hier die Händler hin.
## Seltener Bildschirm: wird beim Öffnen gebaut und beim Schließen freigegeben. Die Run-Szene setzt summary und shop vor dem Einhängen
## (summary: Schlüssel siehe WaveManager.summary).

## Der Spieler will weiter: die nächste Welle beginnt
signal continued

const PixelUI := preload("res://scripts/pixel_ui.gd")
const SOUL_ICON := preload("res://assets/ui/hud_soul.png")
## Sperre nach dem Öffnen gegen versehentliches Antippen (der Daumen steuert gerade noch)
const INPUT_DELAY := 0.6
const DIM_COLOR := Color(0.03, 0.02, 0.06, 0.78)

var summary: Dictionary = {}
var shop: RestShop

var _button: Button
var _reroll_button: Button
var _souls_label: Label
var _cards_row: HBoxContainer
var _empty_label: Label
var _armed := false
var _done := false


func _init() -> void:
	# Läuft auch bei angehaltenem Spiel und blockiert den Joystick
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("joystick_blocker")


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
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 64)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 36)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	var title := Label.new()
	title.text = tr("REST_TITLE") % int(summary.get("wave", 0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_TITLE)
	title.add_theme_color_override("font_color", PixelUI.SELECTED_TEXT_COLOR)
	box.add_child(title)

	var recap := Label.new()
	recap.text = tr("REST_SUMMARY") % [int(summary.get("kills", 0)), int(summary.get("xp", 0)), _format_time(float(summary.get("run_time", 0.0)))]
	recap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(recap)

	# Seelen-Anzeige über den Karten
	var souls_row := HBoxContainer.new()
	souls_row.alignment = BoxContainer.ALIGNMENT_CENTER
	souls_row.add_theme_constant_override("separation", 12)
	var icon := TextureRect.new()
	icon.texture = SOUL_ICON
	icon.custom_minimum_size = Vector2(36.0, 44.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	souls_row.add_child(icon)
	_souls_label = Label.new()
	_souls_label.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_BUTTON)
	_souls_label.add_theme_color_override("font_color", PixelUI.SELECTED_TEXT_COLOR)
	souls_row.add_child(_souls_label)
	box.add_child(souls_row)

	_cards_row = HBoxContainer.new()
	_cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards_row.add_theme_constant_override("separation", 24)
	box.add_child(_cards_row)
	_empty_label = Label.new()
	_empty_label.text = tr("SHOP_EMPTY")
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.visible = false
	box.add_child(_empty_label)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 32)
	_reroll_button = Button.new()
	_reroll_button.custom_minimum_size = Vector2(520.0, 96.0)
	_reroll_button.pressed.connect(_on_reroll_pressed)
	buttons.add_child(_reroll_button)
	_button = Button.new()
	_button.text = tr("REST_CONTINUE")
	_button.custom_minimum_size = Vector2(420.0, 96.0)
	_button.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_BUTTON)
	_button.disabled = true
	_button.pressed.connect(_on_continue_pressed)
	buttons.add_child(_button)
	box.add_child(buttons)

	var next := Label.new()
	var next_seconds := int(summary.get("next_duration", 0.0))
	next.text = tr("REST_NEXT_BOSS" if summary.get("next_boss", false) else "REST_NEXT") % next_seconds
	next.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	next.add_theme_color_override("font_color", PixelUI.TEXT_COLOR)
	box.add_child(next)

	_refresh()
	get_tree().create_timer(INPUT_DELAY, true).timeout.connect(_arm)


## Baut Karten, Seelen-Anzeige und Würfel-Knopf neu auf (nach Kauf oder Neu würfeln)
func _refresh() -> void:
	for child in _cards_row.get_children():
		child.queue_free()
		_cards_row.remove_child(child)
	if not shop:
		return
	_souls_label.text = tr("REST_SOULS") % shop.run_state.souls
	for offer in shop.offers:
		var card := ShopCard.new()
		_cards_row.add_child(card)
		card.setup(offer, shop.can_afford(offer.price))
		card.pressed.connect(_on_card_pressed.bind(offer))
	_empty_label.visible = shop.offers.is_empty()
	var cost := shop.reroll_cost()
	_reroll_button.text = tr("SHOP_REROLL") % cost
	_reroll_button.disabled = shop.run_state.souls < cost


## Sekunden als „m:ss“
static func _format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%d:%02d" % [total / 60, total % 60]


func _arm() -> void:
	_armed = true
	if _button:
		_button.disabled = false


func _on_card_pressed(offer: ShopOffer) -> void:
	if not _armed or _done or not shop:
		return
	if shop.buy(offer):
		_refresh()


func _on_reroll_pressed() -> void:
	if not _armed or _done or not shop:
		return
	if shop.reroll():
		_refresh()


func _on_continue_pressed() -> void:
	if _done:
		return
	_done = true
	continued.emit()
