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
