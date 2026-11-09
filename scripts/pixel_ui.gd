## Hilfsfunktionen für Pixel-Art-UI: vergrößert kleine UI-Texturen pixelgenau
## und baut daraus das gemeinsame Theme für alle Menüs.

## UI-Texturen werden 4× vergrößert
const UI_SCALE := 4

const BUTTON_TEXTURE := preload("res://assets/ui/button.png")
const PANEL_TEXTURE := preload("res://assets/ui/panel.png")
const SLIDER_TRACK_TEXTURE := preload("res://assets/ui/slider_track.png")
const SLIDER_GRABBER_TEXTURE := preload("res://assets/ui/slider_grabber.png")

## Randbreiten der 9-Slice-Texturen (Pixel der Originaltextur)
const BUTTON_MARGIN := 4
const PANEL_MARGIN := 4
const SLIDER_TRACK_MARGIN := 3

const TEXT_COLOR := Color(0.91, 0.87, 0.78)
## Textfarbe eines gewählten Umschaltknopfs (z. B. „Floating“ im Optionsmenü)
const SELECTED_TEXT_COLOR := Color(1.0, 0.8, 0.35)
const OUTLINE_COLOR := Color(0.05, 0.03, 0.08)


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

	var button := nine_slice(BUTTON_TEXTURE, BUTTON_MARGIN)
	button.set_content_margin_all(18)
	var button_pressed := button.duplicate() as StyleBoxTexture
	button_pressed.modulate_color = Color(0.7, 0.7, 0.7)
	var button_disabled := button.duplicate() as StyleBoxTexture
	button_disabled.modulate_color = Color(0.45, 0.45, 0.45, 0.6)
	theme.set_stylebox("disabled", "Button", button_disabled)
	theme.set_color("font_disabled_color", "Button", Color(TEXT_COLOR, 0.35))
	theme.set_stylebox("normal", "Button", button)
	theme.set_stylebox("hover", "Button", button)
	theme.set_stylebox("pressed", "Button", button_pressed)
	theme.set_stylebox("hover_pressed", "Button", button_pressed)
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	theme.set_color("font_color", "Button", TEXT_COLOR)
	theme.set_color("font_hover_color", "Button", TEXT_COLOR)
	theme.set_color("font_focus_color", "Button", TEXT_COLOR)
	theme.set_color("font_pressed_color", "Button", SELECTED_TEXT_COLOR)
	theme.set_color("font_hover_pressed_color", "Button", SELECTED_TEXT_COLOR)
	theme.set_color("font_outline_color", "Button", OUTLINE_COLOR)
	theme.set_constant("outline_size", "Button", 8)
	theme.set_font_size("font_size", "Button", 32)

	var panel := nine_slice(PANEL_TEXTURE, PANEL_MARGIN)
	panel.set_content_margin_all(44)
	theme.set_stylebox("panel", "PanelContainer", panel)

	theme.set_color("font_color", "Label", TEXT_COLOR)
	theme.set_color("font_outline_color", "Label", OUTLINE_COLOR)
	theme.set_constant("outline_size", "Label", 8)
	theme.set_font_size("font_size", "Label", 32)

	var track := nine_slice(SLIDER_TRACK_TEXTURE, SLIDER_TRACK_MARGIN)
	theme.set_stylebox("slider", "HSlider", track)
	theme.set_stylebox("grabber_area", "HSlider", StyleBoxEmpty.new())
	theme.set_stylebox("grabber_area_highlight", "HSlider", StyleBoxEmpty.new())
	var grabber := scaled(SLIDER_GRABBER_TEXTURE)
	theme.set_icon("grabber", "HSlider", grabber)
	theme.set_icon("grabber_highlight", "HSlider", grabber)

	return theme
