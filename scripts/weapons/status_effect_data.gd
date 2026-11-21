class_name StatusEffectData
extends Resource
## Datendatei eines Status-Effekts (data/status/*.tres): Brennen, Gift, Schock, Frost …
## Der EnemyManager speichert pro Gegner nur Restzeit, Takt, Stapel und Stärke (flache Arrays, Bitmaske),
## die Regeln stehen hier. Neuer Status = neue Datei (solange er eine der Arten nutzt).

## DOT: Schaden alle tick_interval Sekunden. SLOW: langsamer laufen. CHAIN: ein Teil des erlittenen Schadens springt
## als Kettenblitz auf nahe Gegner über. STOP: steht still (Freeze, später).
enum Kind { DOT, SLOW, CHAIN, STOP }

@export var id := &""
## Übersetzungsschlüssel des Namens (Debug-Knöpfe, später Tooltips)
@export var name_key := ""
## Element: bestimmt Farbe von Tönung, Partikeln und Schadenszahlen
@export var element: StringName = Elements.PHYSICAL
@export var kind := Kind.DOT
## Wirkdauer in Sekunden. Ein neuer Treffer frischt sie auf.
@export var duration := 3.0
## DOT: Sekunden zwischen zwei Schadens-Ticks
@export var tick_interval := 0.5
## DOT: Schaden pro Tick und Stapel. SLOW: Anteil der Verlangsamung (0.4 = 40 % langsamer). CHAIN: Anteil des Schadens, der überspringt.
@export var power := 20.0
## Wie oft der Status stapeln kann (1 = nur auffrischen). Bei DOT wirkt jeder Stapel voll.
@export var max_stacks := 1
## CHAIN: so viele Gegner trifft der Kettenblitz höchstens, in diesem Umkreis (Welt-Pixel)
@export var chain_targets := 2
@export var chain_range := 64.0
## Wie stark der Gegner in der Elementfarbe getönt wird (0 = gar nicht, 1 = ganz)
@export var tint := 0.45
