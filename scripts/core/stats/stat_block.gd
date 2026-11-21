class_name StatBlock
extends RefCounted
## Sammlung von Boni (StatModifier). Jede Waffe hat einen eigenen Block (ihre Upgrades), dazu gibt es einen globalen Block
## des Helden im RunState (gilt für den Helden und alle Waffen). Neu gerechnet wird nur bei Änderungen, nicht pro Frame:
## Wer Werte liest, merkt sich das Ergebnis, bis changed kommt.

## Ein Bonus kam dazu oder fiel weg
signal changed

var _modifiers: Array[StatModifier] = []


func add(modifier: StatModifier) -> void:
	_modifiers.append(modifier)
	changed.emit()


func remove(modifier: StatModifier) -> void:
	_modifiers.erase(modifier)
	changed.emit()


func clear() -> void:
	_modifiers.clear()
	changed.emit()


func is_empty() -> bool:
	return _modifiers.is_empty()


## Fügt die Summen dieses Blocks für stat zu sums hinzu: sums = [Σ FLAT, Σ PERCENT, Π MULT].
## tags filtert globale Boni (StatModifier.required_tags); null = Held selbst, dann zählen nur Boni ohne Tag-Bedingung.
func accumulate(stat: StringName, sums: PackedFloat32Array, tags: Variant = null) -> void:
	for modifier in _modifiers:
		if modifier.stat != stat:
			continue
		if tags == null:
			if not modifier.required_tags.is_empty():
				continue
		elif not modifier.applies_to(tags):
			continue
		add_to_sums(modifier, sums)


## Rechnet einen einzelnen Bonus in die Summen ein
static func add_to_sums(modifier: StatModifier, sums: PackedFloat32Array) -> void:
	match modifier.kind:
		StatModifier.Kind.FLAT:
			sums[0] += modifier.value
		StatModifier.Kind.PERCENT:
			sums[1] += modifier.value
		StatModifier.Kind.MULT:
			sums[2] *= modifier.value


## Fertiger Wert aus Grundwert und den Summen von accumulate
static func apply(base: float, sums: PackedFloat32Array) -> float:
	return (base + sums[0]) * (1.0 + sums[1]) * sums[2]


## Leere Summen zum Befüllen mit accumulate: [0 FLAT, 0 PERCENT, ×1 MULT]
static func new_sums() -> PackedFloat32Array:
	return PackedFloat32Array([0.0, 0.0, 1.0])


## Fertiger Wert eines Helden-Stats nur aus diesem Block
func calculate(stat: StringName, base: float) -> float:
	var sums := new_sums()
	accumulate(stat, sums)
	return apply(base, sums)
