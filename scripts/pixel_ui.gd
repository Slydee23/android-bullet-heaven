## Hilfsfunktionen für Pixel-Art-UI: vergrößert kleine UI-Texturen pixelgenau.

## UI-Texturen werden wie die Spielwelt 4× vergrößert
const UI_SCALE := 4


## Erzeugt eine StyleBox aus einer 9-Slice-Textur (Ecken bleiben beim Strecken gleich).
## margin = Breite des Randes in Pixeln der Originaltextur.
static func nine_slice(texture: Texture2D, margin: int) -> StyleBoxTexture:
	var image := texture.get_image()
	if image.is_compressed():
		image.decompress()
	image.resize(image.get_width() * UI_SCALE, image.get_height() * UI_SCALE, Image.INTERPOLATE_NEAREST)
	var style := StyleBoxTexture.new()
	style.texture = ImageTexture.create_from_image(image)
	style.set_texture_margin_all(margin * UI_SCALE)
	return style
