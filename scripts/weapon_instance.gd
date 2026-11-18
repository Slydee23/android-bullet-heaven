class_name WeaponInstance
extends RefCounted
## Eine Waffe im laufenden Run: Datendatei plus Zustand (Level, Abklingzeit, Zielwahl, später Upgrades und zusätzliche Effekte).

## Werte haben sich geändert (Upgrade, Debug-Bonus): Dauerwaffen bauen sich daraufhin neu auf.
signal stats_changed

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
## Globale Boni zählen nur für Stats, die die Angriffsart versteht (z. B. kein „+1 Projektil“ für die Aura), und nur bei passenden Tags.
func get_stat(stat: StringName) -> float:
	if _cache.has(stat):
		return _cache[stat]
	var sums := StatBlock.new_sums()
	modifiers.accumulate(stat, sums, data.tags)
	if global_stats and data.behavior and data.behavior.supports_stat(stat):
		global_stats.accumulate(stat, sums, data.tags)
	var value := StatBlock.apply(data.base_stats.get(stat, 0.0), sums)
	var limits: Variant = data.stat_limits.get(stat)
	if limits is Vector2:
		value = clampf(value, limits.x, limits.y)
	if data.behavior:
		value = data.behavior.limit_stat(self, stat, value)
	_cache[stat] = value
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
