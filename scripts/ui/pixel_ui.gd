## Hilfsfunktionen für Pixel-Art-UI: vergrößert kleine UI-Texturen pixelgenau
## und baut daraus das gemeinsame Theme für alle Menüs (Stil „Runenstein & Bann-Siegel“).

## UI-Texturen werden 4× vergrößert (wie das Hauptmenü-Bild)
const UI_SCALE := 4

const FONT := preload("res://assets/fonts/pixel_font.ttf")
const BUTTON_TEXTURE := preload("res://assets/ui/button.png")
const BUTTON_PRESSED_TEXTURE := preload("res://assets/ui/button_pressed.png")
const PANEL_TEXTURE := preload("res://assets/ui/panel.png")
const SLIDER_TRACK_TEXTURE := preload("res://assets/ui/slider_track.png")
const SLIDER_GRABBER_TEXTURE := preload("res://assets/ui/slider_grabber.png")

## Randbreiten der 9-Slice-Texturen (Pixel der Originaltextur)
const BUTTON_MARGIN := 6
const PANEL_MARGIN := 8
const SLIDER_TRACK_MARGIN := 3

## Die Schrift (Jersey 10, angepasst) ist auf einem 16er-Raster gezeichnet: Bei 32, 48, 64, 96 und 128 ist jeder Schriftpixel
## 2, 3, 4, 6 bzw. 8 Bildschirmpixel groß und damit gestochen scharf. Dazwischen wird sie unregelmäßig.
const FONT_SIZE_SMALL := 32
const FONT_SIZE_BUTTON := 48
const FONT_SIZE_HEADER := 48
const FONT_SIZE_TITLE := 64

const TEXT_COLOR := Color(0.91, 0.87, 0.78)
## Textfarbe eines gewählten Umschaltknopfs (z. B. „Floating“ im Optionsmenü) und für Überschriften
const SELECTED_TEXT_COLOR := Color(1.0, 0.8, 0.35)
const OUTLINE_COLOR := Color(0.05, 0.03, 0.08)
## Schlagschatten statt Umrandung: Er bleibt bei der Pixel-Schrift scharf
const SHADOW_OFFSET := Vector2i(2, 3)


## Vergrößert eine Textur pixelgenau um UI_SCALE.
static func scaled(texture: Texture2D) -> ImageTexture:
	var image := texture.get_image()
	if image.is_compressed():
		image.decompress()
	image.resize(image.get_width() * UI_SCALE, image.get_height() * UI_SCALE, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)


## Erzeugt eine StyleBox aus einer 9-Slice-Textur (Ecken bleiben beim Strecken gleich).
## margin = Breite des Randes in Pixeln der Originaltextur.
static func nine_slice(texture: Texture2D, margin: int) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = scaled(texture)
	style.set_texture_margin_all(margin * UI_SCALE)
	return style


## Gemeinsames Theme für alle Menüs: einmal am obersten Control setzen, alle Kinder erben es.
static func make_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = FONT
	theme.default_font_size = FONT_SIZE_SMALL

	var button := nine_slice(BUTTON_TEXTURE, BUTTON_MARGIN)
	button.content_margin_left = 28
	button.content_margin_right = 28
	button.content_margin_top = 14
	button.content_margin_bottom = 18
	var button_hover := button.duplicate() as StyleBoxTexture
	button_hover.modulate_color = Color(1.18, 1.14, 1.28)
	var button_pressed := nine_slice(BUTTON_PRESSED_TEXTURE, BUTTON_MARGIN)
	button_pressed.content_margin_left = 28
	button_pressed.content_margin_right = 28
	# Gedrückt sitzt der Text einen Pixel tiefer, wie bei einer eingedrückten Taste
	button_pressed.content_margin_top = 18
	button_pressed.content_margin_bottom = 14
	var button_disabled := button.duplicate() as StyleBoxTexture
	button_disabled.modulate_color = Color(0.5, 0.5, 0.5, 0.7)
	theme.set_stylebox("disabled", "Button", button_disabled)
	theme.set_color("font_disabled_color", "Button", Color(TEXT_COLOR, 0.35))
	theme.set_stylebox("normal", "Button", button)
	theme.set_stylebox("hover", "Button", button_hover)
	theme.set_stylebox("pressed", "Button", button_pressed)
	theme.set_stylebox("hover_pressed", "Button", button_pressed)
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	theme.set_color("font_color", "Button", TEXT_COLOR)
	theme.set_color("font_hover_color", "Button", TEXT_COLOR)
	theme.set_color("font_focus_color", "Button", TEXT_COLOR)
	theme.set_color("font_pressed_color", "Button", SELECTED_TEXT_COLOR)
	theme.set_color("font_hover_pressed_color", "Button", SELECTED_TEXT_COLOR)
	theme.set_color("font_shadow_color", "Button", OUTLINE_COLOR)
	theme.set_constant("shadow_offset_x", "Button", SHADOW_OFFSET.x)
	theme.set_constant("shadow_offset_y", "Button", SHADOW_OFFSET.y)
	theme.set_constant("outline_size", "Button", 0)
	theme.set_font_size("font_size", "Button", FONT_SIZE_BUTTON)

	var panel := nine_slice(PANEL_TEXTURE, PANEL_MARGIN)
	panel.set_content_margin_all(40)
	theme.set_stylebox("panel", "PanelContainer", panel)

	theme.set_color("font_color", "Label", TEXT_COLOR)
	theme.set_color("font_shadow_color", "Label", OUTLINE_COLOR)
	theme.set_constant("shadow_offset_x", "Label", SHADOW_OFFSET.x)
	theme.set_constant("shadow_offset_y", "Label", SHADOW_OFFSET.y)
	theme.set_constant("outline_size", "Label", 0)
	theme.set_font_size("font_size", "Label", FONT_SIZE_SMALL)

	var track := nine_slice(SLIDER_TRACK_TEXTURE, SLIDER_TRACK_MARGIN)
	theme.set_stylebox("slider", "HSlider", track)
	theme.set_stylebox("grabber_area", "HSlider", StyleBoxEmpty.new())
	theme.set_stylebox("grabber_area_highlight", "HSlider", StyleBoxEmpty.new())
	var grabber := scaled(SLIDER_GRABBER_TEXTURE)
	theme.set_icon("grabber", "HSlider", grabber)
	theme.set_icon("grabber_highlight", "HSlider", grabber)

	return theme
