class_name RestShop
extends RefCounted
## Logik des Seelen-Shops auf dem Rastplatz (Wie bei Brotato): Zufällig gewählte Stat-Boni mit Seltenheit und Preis in Seelen,
## kaufen, gegen steigende Gebühr neu würfeln. Die Boni sind dieselben wie früher auf den Level-Up-Karten (hero_upgrades.tres).
## Bezahlt wird mit RunState.souls, ein Kauf wirkt über RunState.add_hero_upgrade.

## So viele Angebote liegen auf dem Rastplatz
const OFFER_COUNT := 4
## Grundpreis je Seltenheit (gewöhnlich, selten, episch) in Seelen
const BASE_PRICES: Array[int] = [10, 20, 40]
## Preise steigen mit der Welle: +12 % je Welle, aufeinander aufbauend (ca. ×3,5 in Welle 12), damit sie mit den Seelen mitwachsen
const PRICE_GROWTH_PER_WAVE := 0.12
## … und mit jedem in diesem Run gekauften Bonus: +15 % je Kauf (sonst kauft man später den ganzen Shop leer)
const PRICE_GROWTH_PER_PURCHASE := 0.15
## Neu würfeln: erstes Mal REROLL_BASE Seelen, jedes weitere Mal REROLL_STEP mehr (zurückgesetzt je Rastplatz)
const REROLL_BASE := 6
const REROLL_STEP := 3

var pool: UpgradePool
var run_state: RunState
## Nummer der überstandenen Welle (bestimmt die Preise)
var wave := 1
var offers: Array[ShopOffer] = []
var reroll_count := 0
var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()


## Preis eines Bonus in einer Seltenheit in der aktuellen Welle (steigt mit jedem bisher gekauften Bonus).
## factor: Preis-Faktor des Bonus (UpgradeData.price_factor)
func price_for(rarity: int, factor := 1.0) -> int:
	var growth := pow(1.0 + PRICE_GROWTH_PER_WAVE, wave - 1) * (1.0 + PRICE_GROWTH_PER_PURCHASE * run_state.hero_upgrades_total())
	return roundi(BASE_PRICES[rarity] * growth * factor)


## Kosten für das nächste Neu-Würfeln
func reroll_cost() -> int:
	return REROLL_BASE + REROLL_STEP * reroll_count


func can_afford(price: int) -> bool:
	return run_state.souls >= price


## Würfelt neue Angebote: verschiedene Boni, keine, die schon ihren Höchststand (max_stacks) erreicht haben.
## Gekaufte Angebote des alten Satzes verschwinden dabei.
func roll() -> void:
	offers.clear()
	var candidates: Array[UpgradeData] = []
	for upgrade in pool.upgrades:
		if upgrade.max_stacks == 0 or run_state.hero_upgrade_count(upgrade.id) < upgrade.max_stacks:
			candidates.append(upgrade)
	while offers.size() < OFFER_COUNT and not candidates.is_empty():
		var upgrade := _pick_weighted(candidates)
		candidates.erase(upgrade)
		var offer := ShopOffer.new()
		offer.upgrade = upgrade
		offer.rarity = Rarity.roll(rng, upgrade.min_rarity)
		offer.price = price_for(offer.rarity, upgrade.price_factor)
		offers.append(offer)


## Neu würfeln gegen Seelen. Liefert false, wenn sie nicht reichen.
func reroll() -> bool:
	if not run_state.spend_souls(reroll_cost()):
		return false
	reroll_count += 1
	roll()
	return true


## Kauft ein Angebot. Liefert false (und ändert nichts), wenn es schon gekauft ist oder die Seelen nicht reichen.
func buy(offer: ShopOffer) -> bool:
	if offer.bought or not run_state.spend_souls(offer.price):
		return false
	offer.bought = true
	run_state.add_hero_upgrade(offer.upgrade, offer.rarity)
	# Die übrigen Angebote werden teurer
	for other in offers:
		if not other.bought:
			other.price = price_for(other.rarity, other.upgrade.price_factor)
	return true


## Gibt es überhaupt noch etwas zu kaufen (ungekaufte Angebote)?
func has_open_offers() -> bool:
	for offer in offers:
		if not offer.bought:
			return true
	return false


func _pick_weighted(candidates: Array[UpgradeData]) -> UpgradeData:
	var total := 0.0
	for upgrade in candidates:
		total += upgrade.weight
	var pick := rng.randf() * total
	for upgrade in candidates:
		if pick < upgrade.weight:
			return upgrade
		pick -= upgrade.weight
	return candidates[candidates.size() - 1]
