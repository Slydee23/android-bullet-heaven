class_name WeaponHolder
extends Node
## Die Waffen des Helden im Run. Der Held selbst bleibt waffenfrei (Grundsatz 8): Die Run-Szene hängt diesen Baustein an.
## 4 Plätze: 1 Startwaffen-Platz (im Hub gewählt) + 3 Run-Plätze (über Level-Up belegt).

const START_SLOTS := 1
const RUN_SLOTS := 3

var start_weapons: Array[WeaponInstance] = []
var run_weapons: Array[WeaponInstance] = []

var _context := WeaponContext.new()


## Verweise setzen (die Run-Szene ruft das einmal beim Start auf).
func setup(player: Player, enemy_manager: EnemyManager, projectiles: ProjectileManager) -> void:
	_context.player = player
	_context.enemy_manager = enemy_manager
	_context.projectiles = projectiles


func add_start_weapon(data: WeaponData) -> WeaponInstance:
	if start_weapons.size() >= START_SLOTS:
		return null
	var weapon := _register(data)
	start_weapons.append(weapon)
	return weapon


## Neue Waffe auf einen freien Run-Platz (null, wenn voll oder schon vorhanden)
func add_run_weapon(data: WeaponData) -> WeaponInstance:
	if not can_add_run_weapon() or has_weapon(data.id):
		return null
	var weapon := _register(data)
	run_weapons.append(weapon)
	return weapon


func can_add_run_weapon() -> bool:
	return run_weapons.size() < RUN_SLOTS


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
