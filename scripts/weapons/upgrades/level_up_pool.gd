class_name LevelUpPool
extends RefCounted
## Würfelt die Karten eines Level-Ups aus und wendet die gewählte an. Läuft nur beim Level-Up (darf dabei kleine Listen anlegen).
## Kandidaten: neue Waffen (solange ein Run-Platz frei ist, nie eine vorhandene), Upgrades vorhandener Waffen (bis Level 10,
## nur wenn sie den Wert noch verändern, also keine Grenze erreicht ist) und Helden-Boni. Jede Karte wird nach Gewicht gezogen,
## dieselbe Option erscheint nie zweimal. Ist gar nichts mehr übrig, kommt eine Heilungskarte.

## Gewicht einer neuen Waffe (höher als ein einzelnes Upgrade: neue Waffen sollen früh erscheinen)
const NEW_WEAPON_WEIGHT := 3.0
## Helden-Boni sind seltener als Waffen-Upgrades: ihr Gewicht wird damit multipliziert
const HERO_WEIGHT_FACTOR := 0.5
## Heilung der Ersatzkarte (Lebenspunkte)
const HEAL_AMOUNT := 30.0

var catalog: WeaponCatalog
var hero_pool: UpgradePool
var weapons: WeaponHolder
var run_state: RunState
var player: Player
var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()


## Bis zu count verschiedene Karten
func roll(count := 3) -> Array[LevelUpOffer]:
	var candidates: Array[LevelUpOffer] = []
	var weights: Array[float] = []
	if weapons.can_add_run_weapon():
		for data in catalog.unlocked():
			if not weapons.has_weapon(data.id):
				var offer := LevelUpOffer.new()
				offer.kind = LevelUpOffer.Kind.NEW_WEAPON
				offer.weapon_data = data
				candidates.append(offer)
				weights.append(NEW_WEAPON_WEIGHT)
	for weapon in weapons.all_weapons():
		if weapon.level >= WeaponInstance.MAX_LEVEL:
			continue
		for upgrade in weapon.data.upgrades:
			if _weapon_upgrade_useful(weapon, upgrade):
				var offer := LevelUpOffer.new()
				offer.kind = LevelUpOffer.Kind.WEAPON_UPGRADE
				offer.weapon = weapon
				offer.upgrade = upgrade
				candidates.append(offer)
				weights.append(upgrade.weight)
	if hero_pool:
		for upgrade in hero_pool.upgrades:
			if upgrade.max_stacks == 0 or run_state.hero_upgrade_count(upgrade.id) < upgrade.max_stacks:
				var offer := LevelUpOffer.new()
				offer.kind = LevelUpOffer.Kind.HERO_UPGRADE
				offer.upgrade = upgrade
				candidates.append(offer)
				weights.append(upgrade.weight * HERO_WEIGHT_FACTOR)

	var result: Array[LevelUpOffer] = []
	while result.size() < count and not candidates.is_empty():
		var index := _weighted_index(weights)
		var offer := candidates[index]
		candidates.remove_at(index)
		weights.remove_at(index)
		if offer.upgrade:
			offer.rarity = Rarity.roll(rng, offer.upgrade.min_rarity)
		result.append(offer)
	if result.is_empty():
		result.append(LevelUpOffer.new())
	return result


## Wendet die gewählte Karte an
func apply(offer: LevelUpOffer) -> void:
	match offer.kind:
		LevelUpOffer.Kind.NEW_WEAPON:
			weapons.add_run_weapon(offer.weapon_data)
		LevelUpOffer.Kind.WEAPON_UPGRADE:
			weapons.upgrade_weapon(offer.weapon, offer.upgrade, offer.rarity)
		LevelUpOffer.Kind.HERO_UPGRADE:
			run_state.add_hero_upgrade(offer.upgrade, offer.rarity)
		LevelUpOffer.Kind.HEAL:
			player.heal(HEAL_AMOUNT)


## Lohnt sich das Upgrade noch? Die Angriffsart muss den Stat verstehen, das Upgrade darf nicht schon so oft gewählt sein,
## und der Wert muss sich tatsächlich ändern (sonst ist eine Grenze erreicht, z. B. Peitsche schon 8 Hiebe).
func _weapon_upgrade_useful(weapon: WeaponInstance, upgrade: UpgradeData) -> bool:
	if not weapon.data.behavior or not weapon.data.behavior.supports_stat(upgrade.stat):
		return false
	if upgrade.max_stacks > 0 and weapon.upgrade_count(upgrade.id) >= upgrade.max_stacks:
		return false
	var current := weapon.get_stat(upgrade.stat)
	var after := weapon.preview_stat(upgrade.stat, upgrade.make_modifier(upgrade.min_rarity))
	return not is_equal_approx(current, after)


func _weighted_index(weights: Array[float]) -> int:
	var total := 0.0
	for w in weights:
		total += w
	var pick := rng.randf() * total
	for k in weights.size():
		if pick < weights[k]:
			return k
		pick -= weights[k]
	return weights.size() - 1
