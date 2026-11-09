shader_type canvas_item;
// Scharfe Pixel bei krummen Zoomstufen (z. B. 1,75×): Jeder Bildpixel bleibt eine feste Farbe,
// nur der Übergang zwischen zwei Bildpixeln wird über genau einen Bildschirmpunkt weich gerechnet.
// So sind alle Pixel gleich breit, statt abwechselnd 1 und 2 Bildschirmpunkte.
// Voraussetzung: Der Node, der den Shader nutzt, hat den Texturfilter „Linear“.

varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec2 size = vec2(textureSize(TEXTURE, 0));
	vec2 pixel = UV * size;
	vec2 seam = floor(pixel + 0.5);
	vec2 screen_step = max(fwidth(pixel), vec2(0.0001));
	pixel = seam + clamp((pixel - seam) / screen_step, -0.5, 0.5);
	COLOR = texture(TEXTURE, pixel / size) * modulate;
}
