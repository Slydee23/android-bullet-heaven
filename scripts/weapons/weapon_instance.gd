class_name WeaponInstance
extends RefCounted
## Eine Waffe im laufenden Run: Datendatei plus Zustand (Level, Abklingzeit, Zielwahl, später Upgrades und zusätzliche Effekte).

## Werte haben sich geändert (Upgrade, Debug-Bonus): Dauerwaffen bauen sich daraufhin neu auf.
signal stats_changed

## Höchstes Waffenlevel (1 + Anzahl gewählter Upgrades), danach kommt später die Entwicklung
const MAX_LEVEL := 10
## Stats, deren Obergrenze (stat_limits) feste Helden-Boni überschreiten dürfen: „+1 Projektil“ aus dem Shop gibt
## auch einer Waffe am Maximum noch ein Projektil mehr
const LIMIT_BREAK_STATS: Array[StringName] = [&"amount"]

var data: WeaponData
var level := 1
## Erreichte Entwicklungsstufe (0 = noch keine, höchstens data.max_evolution)
var evolution := 0
## Sekunden bis zum nächsten Angriff
var cooldown_left := 0.0
## Wie die Waffe ihre Ziele wählt. Eigene Kopie, damit ein Upgrade sie austauschen kann, ohne die Datendatei zu ändern.
var target_picker: TargetPicker
## Effekte, die erst im Run dazukommen (z. B. durch ein Level-Up-Upgrade), zusätzlich zu data.effects
var extra_effects: Array[WeaponEffect] = []
## Bisher mit dieser Waffe verursachter Schaden (Statusbildschirm)
var total_damage := 0.0
## Dauerwaffen: Ist die Waffe schon bei ihrem Zeichner angemeldet (z. B. die Aura)?
var units_spawned := false
## Dauerwaffen mit Wirkdauer (kreisende Klingen): Restzeit, bis sie wieder verschwinden
var active_left := 0.0

## Eigene Boni dieser Waffe (Level-Up-Upgrades, Debug-Test-Boni)
var modifiers := StatBlock.new()
## Globale Boni des Helden (RunState.stats, setzt der WeaponHolder): gelten für alle Waffen, deren Angriffsart den Stat versteht
var global_stats: StatBlock
## Fertige Werte, bis sich ein Bonus ändert (get_stat wird teils pro Frame gelesen, z. B. Radius der Aura)
var _cache: Dictionary[StringName, float] = {}
## Wie oft jedes Upgrade (UpgradeData.id) gewählt wurde
var upgrade_counts: Dictionary[StringName, int] = {}
## Summe der Werte je Upgrade über alle Wahlen (verschiedene Seltenheiten), für das Detailfenster
var upgrade_totals: Dictionary[StringName, float] = {}


func _init(weapon_data: WeaponData) -> void:
	data = weapon_data
	if data.target_picker:
		target_picker = data.target_picker.duplicate() as TargetPicker
	else:
		target_picker = NearestDistinctPicker.new()
	modifiers.changed.connect(_on_modifiers_changed)


## Verbindet die Waffe mit den globalen Boni des Helden (einmal beim Anlegen)
func set_global_stats(stats: StatBlock) -> void:
	if global_stats:
		global_stats.changed.disconnect(_on_modifiers_changed)
	global_stats = stats
	if global_stats:
		global_stats.changed.connect(_on_modifiers_changed)
	_on_modifiers_changed()


## Fertiger Wert eines Stats: (Grundwert + Σ FLAT) × (1 + Σ PERCENT) × Π MULT aus eigenen und globalen Boni,
## danach begrenzt durch data.stat_limits und die Angriffsart (WeaponBehavior.limit_stat). Ergebnis bleibt bis zur nächsten Änderung gespeichert.
## Ausnahme LIMIT_BREAK_STATS: feste globale Boni (Helden-Boni aus dem Shop) dürfen die Obergrenze um ihren Betrag überschreiten.
## Globale Boni zählen nur für Stats, die die Angriffsart versteht (z. B. kein „+1 Projektil“ für die Aura), und nur bei passenden Tags.
func get_stat(stat: StringName) -> float:
	if _cache.has(stat):
		return _cache[stat]
	var value := _compute(stat, null)
	_cache[stat] = value
	return value


## Wert eines Stats, als ob extra schon gewählt wäre (Vorschau auf der Level-Up-Karte, ändert nichts)
func preview_stat(stat: StringName, extra: StatModifier) -> float:
	return _compute(stat, extra)


## Nimmt ein Level-Up-Upgrade auf: Bonus dazu, Level +1
func apply_upgrade(upgrade: UpgradeData, rarity: int) -> void:
	upgrade_counts[upgrade.id] = upgrade_counts.get(upgrade.id, 0) + 1
	upgrade_totals[upgrade.id] = upgrade_totals.get(upgrade.id, 0.0) + upgrade.value_for(rarity)
	level = mini(level + 1, MAX_LEVEL)
	modifiers.add(upgrade.make_modifier(rarity))


func upgrade_count(id: StringName) -> int:
	return upgrade_counts.get(id, 0)


func _compute(stat: StringName, extra: StatModifier) -> float:
	var sums := StatBlock.new_sums()
	modifiers.accumulate(stat, sums, data.tags)
	if extra and extra.stat == stat:
		StatBlock.add_to_sums(extra, sums)
	var global_flat := 0.0
	if global_stats and data.behavior and data.behavior.supports_stat(stat):
		var flat_before := sums[0]
		global_stats.accumulate(stat, sums, data.tags)
		global_flat = sums[0] - flat_before
	var value := StatBlock.apply(data.base_stats.get(stat, 0.0), sums)
	var limits: Variant = data.stat_limits.get(stat)
	if limits is Vector2:
		var upper: float = limits.y
		if LIMIT_BREAK_STATS.has(stat):
			upper += maxf(global_flat, 0.0)
		value = clampf(value, limits.x, upper)
	if data.behavior:
		value = data.behavior.limit_stat(self, stat, value)
	return value


## Fester Bonus auf einen Stat (Debug-Test-Boni)
func add_flat(stat: StringName, value: float) -> void:
	modifiers.add(StatModifier.create(stat, StatModifier.Kind.FLAT, value))


## Nimmt alle eigenen Boni zurück (Debug)
func reset_bonuses() -> void:
	modifiers.clear()


func _on_modifiers_changed() -> void:
	_cache.clear()
	stats_changed.emit()
