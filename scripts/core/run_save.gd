class_name RunSave
extends RefCounted
## Run-Spielstand (run.save im gewählten Speicherplatz, siehe SaveSlots): sichert einen Run am Anfang jeder Welle und auf dem Rastplatz, damit er sich nach dem
## Beenden der App fortsetzen lässt. Gespeichert werden nur IDs und Zahlen (keine Bilder oder Texte), als lesbares JSON.
## Wird mitten in einer Welle beendet, beginnt diese Welle beim Fortsetzen von vorn (Entscheidung M8).
## Strikt getrennt vom späteren Profil-Spielstand (E6): Tod, Sieg oder Aufgeben löschen nur diese Datei.

const FILE_NAME := "run.save"
## Format des Spielstands. Ändert sich der Aufbau, wird die Zahl erhöht und alte Stände in read() umgewandelt.
const FORMAT_VERSION := 1

## Run steht am Anfang einer Welle (wave = diese Welle) bzw. auf dem Rastplatz (wave = gerade überstandene Welle)
const PHASE_WAVE := "wave"
const PHASE_REST := "rest"


## Pfad des Run-Spielstands im gewählten Speicherplatz
static func path() -> String:
	return SaveSlots.current_dir() + "/" + FILE_NAME


static func temp_path() -> String:
	return path() + ".tmp"


static func exists() -> bool:
	return FileAccess.file_exists(path())


## Liest den Run-Spielstand eines bestimmten Platzes (für das Lade-Menü), ohne den gewählten Platz zu ändern
static func read_slot(index: int) -> Dictionary:
	var before := SaveSlots.current
	SaveSlots.current = index
	var data := read()
	SaveSlots.current = before
	return data


static func delete() -> void:
	for file_path in [path(), temp_path()]:
		if FileAccess.file_exists(file_path):
			DirAccess.remove_absolute(file_path)


## Schreibt sicher: erst in eine Zwischendatei, dann austauschen. Stürzt das Spiel beim Schreiben ab, bleibt der alte Stand.
static func write(data: Dictionary) -> bool:
	data["format"] = FORMAT_VERSION
	data["game_version"] = str(ProjectSettings.get_setting("application/config/version", ""))
	SaveSlots.touch(SaveSlots.current)
	var file := FileAccess.open(temp_path(), FileAccess.WRITE)
	if not file:
		push_warning("RunSave: Zwischendatei nicht schreibbar (%d)" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	if DirAccess.rename_absolute(temp_path(), path()) != OK:
		# Manche Systeme ersetzen beim Umbenennen nicht: alte Datei weg, dann erneut
		DirAccess.remove_absolute(path())
		if DirAccess.rename_absolute(temp_path(), path()) != OK:
			push_warning("RunSave: Spielstand konnte nicht ersetzt werden")
			return false
	return true


## Liest den Spielstand. Leer, wenn keiner da ist oder er unlesbar bzw. aus einem unbekannten, neueren Format ist.
static func read() -> Dictionary:
	if not exists():
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path()))
	if not parsed is Dictionary:
		push_warning("RunSave: Spielstand unlesbar")
		return {}
	var data: Dictionary = parsed
	var format := int(data.get("format", 0))
	if format < 1 or format > FORMAT_VERSION:
		push_warning("RunSave: unbekanntes Format %d" % format)
		return {}
	# Hier kommen später Umwandlungen alter Formate hin (z. B. if format == 1: … ; format = 2)
	return data


# --- Erfassen ---------------------------------------------------------------------------------------------------------

## Momentaufnahme des Runs. phase: PHASE_WAVE oder PHASE_REST, wave: Wellennummer (siehe oben).
## rest: auf dem Rastplatz die Zusammenfassung der Welle und der Shop (sonst leer).
static func capture(phase: String, wave: int, run_state: RunState, player: Player, weapons: WeaponHolder,
		summary: Dictionary = {}, shop: RestShop = null) -> Dictionary:
	var data := {
		"phase": phase,
		"wave": wave,
		"wave_total": run_state.wave_total,
		"run": {
			"level": run_state.level,
			"xp": run_state.xp,
			"xp_gained": run_state.xp_gained,
			"souls": run_state.souls,
			"souls_earned": run_state.souls_earned,
			"kills": run_state.kills,
			"time": run_state.time,
			"rerolls": run_state.rerolls,
			"hero_upgrades": run_state.hero_upgrade_log.duplicate(true),
		},
		"hp": player.hp,
		"start_weapons": _weapons_to_list(weapons.start_weapons),
		"run_weapons": _weapons_to_list(weapons.run_weapons),
	}
	if phase == PHASE_REST:
		data["summary"] = summary.duplicate()
		if shop:
			data["shop"] = _shop_to_dict(shop)
	return data


static func _weapons_to_list(list: Array[WeaponInstance]) -> Array:
	var result := []
	for weapon in list:
		result.append({
			"id": String(weapon.data.id),
			"upgrades": weapon.upgrade_log.duplicate(true),
			"total_damage": weapon.total_damage,
		})
	return result


static func _shop_to_dict(shop: RestShop) -> Dictionary:
	var offers := []
	for offer in shop.offers:
		offers.append({"id": String(offer.upgrade.id), "rarity": offer.rarity, "price": offer.price, "bought": offer.bought})
	return {"offers": offers, "reroll_count": shop.reroll_count}


# --- Wiederherstellen -------------------------------------------------------------------------------------------------

## Stellt Stufe, Erfahrung, Seelen, Statistik und gekaufte Helden-Boni wieder her (auf einem frischen RunState).
static func restore_run_state(data: Dictionary, run_state: RunState, hero_pool: UpgradePool) -> void:
	var run: Dictionary = data.get("run", {})
	for entry in run.get("hero_upgrades", []):
		var upgrade := _find_upgrade(hero_pool.upgrades, StringName(entry.get("id", "")))
		if upgrade:
			run_state.add_hero_upgrade(upgrade, int(entry.get("rarity", 0)))
	run_state.level = int(run.get("level", 1))
	run_state.xp = int(run.get("xp", 0))
	run_state.xp_gained = int(run.get("xp_gained", 0))
	run_state.souls = int(run.get("souls", 0))
	run_state.souls_earned = int(run.get("souls_earned", 0))
	run_state.kills = int(run.get("kills", 0))
	run_state.time = float(run.get("time", 0.0))
	run_state.rerolls = int(run.get("rerolls", RunState.START_REROLLS))
	run_state.xp_changed.emit(run_state.xp, run_state.xp_needed())
	run_state.souls_changed.emit(run_state.souls)


## Baut die Waffen wieder auf: Startwaffe (falls eine andere gespeichert ist) und Run-Waffen, jeweils mit allen Upgrades
## in der gewählten Reihenfolge und Seltenheit.
static func restore_weapons(data: Dictionary, weapons: WeaponHolder, catalog: WeaponCatalog) -> void:
	var start_list: Array = data.get("start_weapons", [])
	if not start_list.is_empty():
		var entry: Dictionary = start_list[0]
		var start_data := _find_weapon(catalog, StringName(entry.get("id", "")))
		if start_data:
			var weapon: WeaponInstance
			if not weapons.start_weapons.is_empty() and weapons.start_weapons[0].data == start_data:
				weapon = weapons.start_weapons[0]
			else:
				weapon = weapons.replace_start_weapon(start_data)
			_restore_upgrades(entry, weapon, weapons)
	for entry in data.get("run_weapons", []):
		var weapon_data := _find_weapon(catalog, StringName(entry.get("id", "")))
		if weapon_data:
			var weapon := weapons.add_run_weapon(weapon_data)
			if weapon:
				_restore_upgrades(entry, weapon, weapons)


static func _restore_upgrades(entry: Dictionary, weapon: WeaponInstance, weapons: WeaponHolder) -> void:
	for upgrade_entry in entry.get("upgrades", []):
		var upgrade := _find_upgrade(weapon.data.upgrades, StringName(upgrade_entry.get("id", "")))
		if upgrade:
			weapons.upgrade_weapon(weapon, upgrade, int(upgrade_entry.get("rarity", 0)))
	weapon.total_damage = float(entry.get("total_damage", 0.0))


## Lebenspunkte des Helden (nach den Boni, damit die Max-HP schon stimmen)
static func restore_hp(data: Dictionary, player: Player) -> void:
	player.restore_hp(float(data.get("hp", player.max_hp)))


## Shop des Rastplatzes mit genau den gespeicherten Angeboten (kein Neu-Würfeln durch Neuladen)
static func restore_shop(data: Dictionary, shop: RestShop) -> void:
	var saved: Dictionary = data.get("shop", {})
	shop.offers.clear()
	for entry in saved.get("offers", []):
		var upgrade := _find_upgrade(shop.pool.upgrades, StringName(entry.get("id", "")))
		if not upgrade:
			continue
		var offer := ShopOffer.new()
		offer.upgrade = upgrade
		offer.rarity = int(entry.get("rarity", 0))
		offer.price = int(entry.get("price", 0))
		offer.bought = bool(entry.get("bought", false))
		shop.offers.append(offer)
	shop.reroll_count = int(saved.get("reroll_count", 0))


static func _find_weapon(catalog: WeaponCatalog, id: StringName) -> WeaponData:
	for weapon_data in catalog.weapons:
		if weapon_data.id == id:
			return weapon_data
	return null


static func _find_upgrade(list: Array[UpgradeData], id: StringName) -> UpgradeData:
	for upgrade in list:
		if upgrade.id == id:
			return upgrade
	return null
