class_name Palette
extends RefCounted
## Gemeinsame Farbpalette der Spielwelt-Grafiken. Erzeugt von tools/extract_palette.gd aus Held und Skelett
## (32 Farben aus 84 verschiedenen), darf von Hand angepasst werden.
## Platzhalter-Generatoren der Spielwelt (nicht der UI) färben ihre Bilder mit snap() auf diese Farben ein.

const COLORS: Array[Color] = [
	Color("#000000"),
	Color("#542a4d"),
	Color("#f4f6f0"),
	Color("#cdfcfa"),
	Color("#f9c769"),
	Color("#9a8163"),
	Color("#ddd4b5"),
	Color("#7c394d"),
	Color("#784030"),
	Color("#514043"),
	Color("#62b8da"),
	Color("#b96e36"),
	Color("#376281"),
	Color("#e7a374"),
	Color("#924b35"),
	Color("#8a6e52"),
	Color("#f5cdae"),
	Color("#ebe8d4"),
	Color("#404a66"),
	Color("#a45b30"),
	Color("#cb8038"),
	Color("#332930"),
	Color("#447a9a"),
	Color("#ce7360"),
	Color("#de8d73"),
	Color("#680d19"),
	Color("#8ecbdc"),
	Color("#6898b2"),
	Color("#352a4e"),
	Color("#c45836"),
	Color("#cdbf9b"),
	Color("#0c0d0f"),
]


## Die Palettenfarbe, die c am nächsten liegt (Alpha bleibt erhalten).
static func snap(c: Color) -> Color:
	var best := COLORS[0]
	var best_distance := INF
	for p in COLORS:
		var d := Vector3(c.r - p.r, c.g - p.g, c.b - p.b).length_squared()
		if d < best_distance:
			best_distance = d
			best = p
	return Color(best, c.a)
