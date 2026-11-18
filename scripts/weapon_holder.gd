class_name WeaponHolder
extends Node
## Die Waffen des Helden im Run. Der Held selbst bleibt waffenfrei (Grundsatz 8): Die Run-Szene hängt diesen Baustein an.
## 4 Plätze: 1 Startwaffen-Platz (im Hub gewählt) + 3 Run-Plätze (über Level-Up belegt).

## Waffen kamen dazu, wurden getauscht oder entfernt (für die Waffenplätze im HUD)
signal weapons_changed

const START_SLOTS := 1
const RUN_SLOTS := 3

var start_weapons: Array[WeaponInstance] = []
var run_weapons: Array[WeaponInstance] = []

## Globale Boni des Helden (RunState.stats), gelten für alle Waffen (setzt die Run-Szene vor der ersten Waffe)
var global_stats: StatBlock

var _context := WeaponContext.new()


## Verweise setzen (die Run-Szene ruft das einmal beim Start auf).
func setup(player: Player, enemy_manager: EnemyManager, projectiles: ProjectileManager, auras: AuraDrawer, strikes: StrikeManager, effects: EffectManager) -> void:
	_context.player = player
	_context.enemy_manager = enemy_manager
	_context.projectiles = projectiles
	_context.auras = auras
	_context.strikes = strikes
	_context.effects = effects


func add_start_weapon(data: WeaponData) -> WeaponInstance:
	if start_weapons.size() >= START_SLOTS:
		return null
	var weapon := _register(data)
	start_weapons.append(weapon)
	weapons_changed.emit()
	return weapon


## Neue Waffe auf einen freien Run-Platz (null, wenn voll oder schon vorhanden)
func add_run_weapon(data: WeaponData) -> WeaponInstance:
	if not can_add_run_weapon() or has_weapon(data.id):
		return null
	var weapon := _register(data)
	run_weapons.append(weapon)
	weapons_changed.emit()
	return weapon


## Tauscht die Startwaffe aus (Debug „Startwaffe wechseln“): Die alte räumt ihre Klingen, Auren und Einschläge weg.
func replace_start_weapon(data: WeaponData) -> WeaponInstance:
	for weapon in start_weapons:
		weapon.data.behavior.on_removed(weapon, _context)
	start_weapons.clear()
	var weapon := _register(data)
	start_weapons.append(weapon)
	weapons_changed.emit()
	return weapon


## Legt alle Run-Waffen ab (Debug). Jede Angriffsart räumt dabei ihre Klingen, Auren und Einschläge weg.
func clear_run_weapons() -> void:
	for weapon in run_weapons:
		weapon.data.behavior.on_removed(weapon, _context)
	run_weapons.clear()
	weapons_changed.emit()


## Level-Up-Upgrade auf eine Waffe (Level +1, Bonus dazu)
func upgrade_weapon(weapon: WeaponInstance, upgrade: UpgradeData, rarity: int) -> void:
	weapon.apply_upgrade(upgrade, rarity)
	weapons_changed.emit()


func can_add_run_weapon() -> bool:
	return run_weapons.size() < RUN_SLOTS


## Alle Waffen (Startplatz zuerst). Erzeugt ein neues Array: für Menüs und Debug, nicht pro Frame.
func all_weapons() -> Array[WeaponInstance]:
	var result: Array[WeaponInstance] = []
	result.append_array(start_weapons)
	result.append_array(run_weapons)
	return result


func has_weapon(id: StringName) -> bool:
	for weapon in start_weapons:
		if weapon.data.id == id:
			return true
	for weapon in run_weapons:
		if weapon.data.id == id:
			return true
	return false


func _register(data: WeaponData) -> WeaponInstance:
	var weapon := WeaponInstance.new(data)
	weapon.set_global_stats(global_stats)
	weapon.stats_changed.connect(_on_stats_changed.bind(weapon))
	return weapon


func _on_stats_changed(weapon: WeaponInstance) -> void:
	if _context.player:
		weapon.data.behavior.on_stats_changed(weapon, _context)


func _process(delta: float) -> void:
	if not _context.player:
		return
	for weapon in start_weapons:
		_update_weapon(weapon, delta)
	for weapon in run_weapons:
		_update_weapon(weapon, delta)


func _update_weapon(weapon: WeaponInstance, delta: float) -> void:
	var behavior := weapon.data.behavior
	behavior.tick(weapon, _context, delta)
	weapon.cooldown_left -= delta
	if weapon.cooldown_left > 0.0:
		return
	if behavior.fire(weapon, _context):
		weapon.cooldown_left = weapon.get_stat(&"cooldown")
	else:
		# Kein Ziel in Reichweite: Die Waffe bleibt schussbereit
		weapon.cooldown_left = 0.0
