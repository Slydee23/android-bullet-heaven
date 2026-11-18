class_name LevelUpCard
extends Button
## Eine Karte im Level-Up-Fenster: Runenstein-Karte mit Rand in der Seltenheitsfarbe, oben das Icon, darunter Name,
## „Neue Waffe“ bzw. „Lv 3 → 4“ und die Wirkung (bei Waffen-Upgrades als „Wert alt → neu“).

const PixelUI := preload("res://scripts/pixel_ui.gd")
const CARD_TEXTURES: Array[Texture2D] = [
	preload("res://assets/ui/card_common.png"),
	preload("res://assets/ui/card_rare.png"),
	preload("res://assets/ui/card_epic.png"),
]
const CARD_MARGIN := 8
const HEAL_ICON := preload("res://assets/sprites/icons/bonus_heal.png")
const CARD_SIZE := Vector2(440.0, 680.0)
## Icons (32×32) werden 3× gezeichnet
const ICON_SIZE := Vector2(96.0, 96.0)
const CONTENT_MARGIN := 44

var offer: LevelUpOffer

var _rarity_label := Label.new()
var _icon := TextureRect.new()
var _name_label := Label.new()
var _level_label := Label.new()
var _description_label := Label.new()


func _init() -> void:
	custom_minimum_size = CARD_SIZE
	focus_mode = Control.FOCUS_NONE
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, CONTENT_MARGIN)
	add_child(margin)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)
	_rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_icon.custom_minimum_size = ICON_SIZE
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_name_label.add_theme_font_size_override("font_size", PixelUI.FONT_SIZE_BUTTON)
	_level_label.add_theme_color_override("font_color", PixelUI.SELECTED_TEXT_COLOR)
	_description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for label in [_name_label, _level_label, _description_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for node in [_rarity_label, _icon, _name_label, _level_label, _description_label]:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(node)


## Füllt die Karte (nach dem Einhängen in den Baum aufrufen, damit tr() die Sprache kennt)
func setup(card_offer: LevelUpOffer) -> void:
	offer = card_offer
	_apply_style(offer.rarity if offer.upgrade else Rarity.COMMON)
	_rarity_label.text = ""
	if offer.upgrade and offer.rarity > Rarity.COMMON:
		_rarity_label.text = tr(Rarity.NAME_KEYS[offer.rarity])
		_rarity_label.add_theme_color_override("font_color", Rarity.COLORS[offer.rarity])
	match offer.kind:
		LevelUpOffer.Kind.NEW_WEAPON:
			_icon.texture = offer.weapon_data.icon
			_name_label.text = tr(offer.weapon_data.name_key)
			_level_label.text = tr("LEVEL_UP_NEW")
			_description_label.text = tr(offer.weapon_data.description_key)
		LevelUpOffer.Kind.WEAPON_UPGRADE:
			var weapon := offer.weapon
			var stat := offer.upgrade.stat
			_icon.texture = weapon.data.icon
			_name_label.text = tr(weapon.data.name_key)
			_level_label.text = tr("LEVEL_UP_LEVEL") % [weapon.level, mini(weapon.level + 1, WeaponInstance.MAX_LEVEL)]
			var after := weapon.preview_stat(stat, offer.upgrade.make_modifier(offer.rarity))
			_description_label.text = tr("LEVEL_UP_STAT_CHANGE") % [
				tr(WeaponStatDisplay.label_key(weapon, stat)),
				WeaponStatDisplay.value_text(weapon, stat, tr),
				WeaponStatDisplay.format_value(weapon, stat, after, tr),
			]
		LevelUpOffer.Kind.HERO_UPGRADE:
			_icon.texture = offer.upgrade.icon
			_name_label.text = tr(offer.upgrade.name_key)
			_level_label.text = tr("LEVEL_UP_HERO")
			_description_label.text = tr(offer.upgrade.description_key) % offer.upgrade.value_text(offer.rarity)
		LevelUpOffer.Kind.HEAL:
			_icon.texture = HEAL_ICON
			_name_label.text = tr("LEVEL_UP_HEAL_NAME")
			_level_label.text = ""
			_description_label.text = tr("LEVEL_UP_HEAL_DESC") % roundi(LevelUpPool.HEAL_AMOUNT)


func _apply_style(rarity: int) -> void:
	var normal := PixelUI.nine_slice(CARD_TEXTURES[rarity], CARD_MARGIN)
	var hover := normal.duplicate() as StyleBoxTexture
	hover.modulate_color = Color(1.18, 1.14, 1.28)
	var pressed := normal.duplicate() as StyleBoxTexture
	pressed.modulate_color = Color(0.8, 0.78, 0.85)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed)
	add_theme_stylebox_override("hover_pressed", pressed)
	# Während der kurzen Eingabesperre sieht die Karte normal aus (nur nicht antippbar)
	add_theme_stylebox_override("disabled", normal)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
