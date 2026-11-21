class_name UpgradeData
extends Resource
## Ein Level-Up-Upgrade: verändert genau einen Stat (als StatModifier), entweder einer Waffe (Pool in WeaponData.upgrades)
## oder des Helden und aller Waffen (Helden-Boni, data/upgrades/hero_upgrades.tres). Neues Upgrade = neuer Eintrag, kein Code.

@export var id := &""
@export var stat := &""
@export var kind := StatModifier.Kind.FLAT
## Wert bei „Gewöhnlich“ (selten und episch: × Rarity.MULTIPLIERS), z. B. 10 = +10 Schaden, -0.08 = −8 % Abklingzeit
@export var value := 0.0
## Optional feste Werte je Seltenheit [gewöhnlich, selten, episch] statt der Multiplikatoren (z. B. Projektile: [0, 1, 2])
@export var rarity_values := PackedFloat32Array()
## Niedrigste Seltenheit, in der das Upgrade erscheint (Rarity.COMMON/RARE/EPIC)
@export var min_rarity := Rarity.COMMON
## Gewicht im Zufalls-Pool (höher = häufiger)
@export var weight := 1.0
## Nur Seelen-Shop: Preis-Faktor (z. B. 1.5 = 50 % teurer für besonders starke Boni wie „+1 Projektil“)
@export var price_factor := 1.0
## Wie oft man es höchstens wählen kann (0 = unbegrenzt, bei Waffen begrenzt dann das Waffenlevel)
@export var max_stacks := 0
## Helden-Boni: Name und Beschreibung (z. B. „Schaden aller Waffen %s“), Waffen-Upgrades zeigen stattdessen „Wert alt → neu“
@export var name_key := ""
@export var description_key := ""
## Helden-Boni: Symbol auf der Karte
@export var icon: Texture2D


func value_for(rarity: int) -> float:
	if rarity < rarity_values.size():
		return rarity_values[rarity]
	var result := value * Rarity.MULTIPLIERS[rarity]
	# Ganzzahlige feste Boni bleiben ganzzahlig (15 Max-HP × 1,5 = 23 statt 22,5)
	if kind == StatModifier.Kind.FLAT and is_equal_approx(value, roundf(value)):
		result = roundf(result)
	return result


func make_modifier(rarity: int) -> StatModifier:
	return StatModifier.create(stat, kind, value_for(rarity))


## Wert als kurzer Text mit Vorzeichen: „+8 %“, „−0.1“, „+15“
func value_text(rarity: int) -> String:
	return format_amount(value_for(rarity))


## Beliebigen Betrag dieses Upgrades als Text (z. B. die Summe mehrerer Wahlen im Detailfenster der Waffe)
func format_amount(v: float) -> String:
	var prefix := "+" if v >= 0.0 else "−"
	if kind == StatModifier.Kind.PERCENT:
		return "%s%d %%" % [prefix, roundi(absf(v) * 100.0)]
	var magnitude := absf(v)
	if is_equal_approx(magnitude, roundf(magnitude)):
		return "%s%d" % [prefix, roundi(magnitude)]
	return "%s%s" % [prefix, str(snappedf(magnitude, 0.01))]
