class_name Elements
extends RefCounted
## Elemente (Schadens-Tags): Jede Waffe hat genau eines. `physical` (Anzeige „Physisch“) ist der Standard für Waffen ohne Element.
## Boni, Resistenzen und Schadenszahl-Farben (M4c) hängen später an diesen IDs.

const PHYSICAL := &"physical"
const FIRE := &"fire"
const LIGHTNING := &"lightning"
const POISON := &"poison"
const COLD := &"cold"

const ALL: Array[StringName] = [PHYSICAL, FIRE, LIGHTNING, POISON, COLD]

## Farben der Schadenszahlen (hell, mit dunklem Rand lesbar auf dem Waldboden). Feuer ist ein helles Rotorange, damit es sich
## auch auf kleinen Bildschirmen vom Boden abhebt. Gift ist ein helles Limettengrün, weil dunkles Grün im Gras untergeht.
const COLOR_PHYSICAL := Color("#f4f6f0")
const COLOR_FIRE := Color("#ff6a3d")
const COLOR_LIGHTNING := Color("#ffe14a")
const COLOR_POISON := Color("#b6f03c")
const COLOR_COLD := Color("#8fdcff")
## Kritischer physischer Treffer (Elemente behalten ihre Farbe, ein Crit zeigt sich dort nur durch Größe und „!“)
const COLOR_CRIT_PHYSICAL := Color("#f9c769")


## Farbe der Schadenszahl für ein Element
static func damage_color(element: StringName, crit: bool) -> Color:
	match element:
		FIRE:
			return COLOR_FIRE
		LIGHTNING:
			return COLOR_LIGHTNING
		POISON:
			return COLOR_POISON
		COLD:
			return COLOR_COLD
	return COLOR_CRIT_PHYSICAL if crit else COLOR_PHYSICAL
