class_name Rarity
extends RefCounted
## Seltenheit von Level-Up-Upgrades: Gewöhnlich, Selten, Episch. Seltene Upgrades sind stärker und erscheinen seltener.
## Später kann ein Glück-Wert die Chancen verschieben.

const COMMON := 0
const RARE := 1
const EPIC := 2

## Wahrscheinlichkeit je Stufe (Gewichte, müssen nicht 100 ergeben)
const WEIGHTS: Array[float] = [70.0, 25.0, 5.0]
## Stärke je Stufe, wenn ein Upgrade keine eigenen Werte je Seltenheit hat
const MULTIPLIERS: Array[float] = [1.0, 1.5, 2.0]
const NAME_KEYS: Array[String] = ["RARITY_COMMON", "RARITY_RARE", "RARITY_EPIC"]
## Randfarbe der Karte (passend zu den Karten-Texturen card_common/rare/epic)
const COLORS: Array[Color] = [Color("#b8b0c8"), Color("#62b8da"), Color("#b49cff")]


## Zufällige Seltenheit, mindestens minimum
static func roll(rng: RandomNumberGenerator, minimum := COMMON) -> int:
	var total := 0.0
	for w in WEIGHTS:
		total += w
	var pick := rng.randf() * total
	var result := COMMON
	for k in WEIGHTS.size():
		if pick < WEIGHTS[k]:
			result = k
			break
		pick -= WEIGHTS[k]
	return maxi(result, minimum)
