class_name StatModifier
extends Resource
## Ein Bonus auf einen Wert (Stat), z. B. „+10 Schaden“, „+15 % Schaden“ oder „× 1,5 Wirkbereich“.
## Liefern Level-Up-Upgrades, später Artefakte, Rüstung und Dorf-Upgrades (siehe PLAN.md Grundsatz 6).
## Rechnung im StatBlock: Endwert = (Grundwert + Σ FLAT) × (1 + Σ PERCENT) × Π MULT

enum Kind {
	## Fester Betrag, wird zum Grundwert addiert
	FLAT,
	## Anteil, 0.1 = +10 %; Prozent-Boni addieren sich untereinander (+20 % und +15 % = +35 %)
	PERCENT,
	## Sonder-Multiplikator für seltene Quellen (z. B. Entwicklungen), mehrere werden multipliziert
	MULT,
}

@export var stat := &""
@export var kind := Kind.FLAT
@export var value := 0.0
## Nur für Waffen mit allen diesen Tags (z. B. [&"projectile"]); leer = für alle. Gilt nur bei globalen Boni des Helden.
@export var required_tags: Array[StringName] = []


static func create(stat_id: StringName, modifier_kind: Kind, amount: float, tags: Array[StringName] = []) -> StatModifier:
	var modifier := StatModifier.new()
	modifier.stat = stat_id
	modifier.kind = modifier_kind
	modifier.value = amount
	modifier.required_tags = tags
	return modifier


## Gilt dieser Bonus für eine Waffe mit diesen Tags?
func applies_to(tags: Array[StringName]) -> bool:
	for tag in required_tags:
		if tag not in tags:
			return false
	return true
