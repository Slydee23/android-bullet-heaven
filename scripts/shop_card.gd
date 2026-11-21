class_name ShopCard
extends Button
## Eine Karte im Rastplatz-Shop: Runenstein-Karte mit Rand in der Seltenheitsfarbe (wie die Level-Up-Karten, nur kleiner),
## Icon, Name, Wirkung („Lauftempo +8 %“) und Preis in Seelen. Nicht bezahlbar: Preis rot. Gekauft: blass, „Gekauft“.

const PixelUI := preload("res://scripts/pixel_ui.gd")
const SOUL_ICON := preload("res://assets/ui/hud_soul.png")
const CARD_MARGIN := 8
const CARD_SIZE := Vector2(360.0, 430.0)
## Icons (32×32) werden 3× gezeichnet
const ICON_SIZE := Vector2(96.0, 96.0)
const CONTENT_MARGIN := 32
const UNAFFORDABLE_COLOR := Color(1.0, 0.45, 0.4)
const BOUGHT_MODULATE := Color(1.0, 1.0, 1.0, 0.35)

var offer: ShopOffer

var _rarity_label := Label.new()
var _icon := TextureRect.new()
var _name_label := Label.new()
var _effect_label := Label.new()
var _price_box := HBoxContainer.new()
var _price_icon := TextureRect.new()
var _price_label := Label.new()


func _init() -> void:
	custom_minimum_size = CARD_SIZE
	focus_mode = Control.FOCUS_NONE
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, CONTENT_MARGIN)
	add_child(margin)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	_rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_rarity_label.custom_minimum_size = Vector2(0.0, 36.0)
	_icon.custom_minimum_size = ICON_SIZE
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_name_label.add_theme_color_override("font_color", PixelUI.TEXT_COLOR)
	_effect_label.add_theme_color_override("font_color", PixelUI.SELECTED_TEXT_COLOR)
	_effect_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for label in [_name_label, _effect_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_price_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_price_box.add_theme_constant_override("separation", 12)
	_price_icon.texture = SOUL_ICON
	_price_icon.custom_minimum_size = Vector2(36.0, 44.0)
	_price_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_price_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_price_label.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_BUTTON)
	_price_box.add_child(_price_icon)
	_price_box.add_child(_price_label)
	for node in [_rarity_label, _icon, _name_label, _effect_label, _price_box]:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(node)
	for node in [_price_icon, _price_label]:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Füllt die Karte (nach dem Einhängen in den Baum aufrufen, damit tr() die Sprache kennt)
func setup(shop_offer: ShopOffer, affordable: bool) -> void:
	offer = shop_offer
	_apply_style(offer.rarity)
	var upgrade := offer.upgrade
	_rarity_label.text = ""
	if offer.rarity > Rarity.COMMON:
		_rarity_label.text = tr(Rarity.NAME_KEYS[offer.rarity])
		_rarity_label.add_theme_color_override("font_color", Rarity.COLORS[offer.rarity])
	_icon.texture = upgrade.icon
	_name_label.text = tr(upgrade.name_key)
	_effect_label.text = tr(upgrade.description_key) % upgrade.value_text(offer.rarity)
	if offer.bought:
		modulate = BOUGHT_MODULATE
		disabled = true
		_price_icon.visible = false
		_price_label.text = tr("SHOP_BOUGHT")
		_price_label.add_theme_color_override("font_color", PixelUI.TEXT_COLOR)
		return
	modulate = Color.WHITE
	disabled = false
	_price_icon.visible = true
	_price_label.text = str(offer.price)
	_price_label.add_theme_color_override("font_color", PixelUI.TEXT_COLOR if affordable else UNAFFORDABLE_COLOR)


func _apply_style(rarity: int) -> void:
	var normal := PixelUI.nine_slice(LevelUpCard.CARD_TEXTURES[rarity], CARD_MARGIN)
	var hover := normal.duplicate() as StyleBoxTexture
	hover.modulate_color = Color(1.18, 1.14, 1.28)
	var pressed := normal.duplicate() as StyleBoxTexture
	pressed.modulate_color = Color(0.8, 0.78, 0.85)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed)
	add_theme_stylebox_override("hover_pressed", pressed)
	add_theme_stylebox_override("disabled", normal)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
