class_name WeaponHolder
extends Node
## Die Waffen des Helden im Run. Der Held selbst bleibt waffenfrei (Grundsatz 8): Die Run-Szene hängt diesen Baustein an.
## 4 Plätze: 1 Startwaffen-Platz (im Hub gewählt) + 3 Run-Plätze (über Level-Up belegt).

const START_SLOTS := 1
const RUN_SLOTS := 3

var player: Player
var enemy_manager: EnemyManager
var projectiles: ProjectileManager
var start_weapons: Array[WeaponInstance] = []
var run_weapons: Array[WeaponInstance] = []


func add_start_weapon(data: WeaponData) -> WeaponInstance:
	if start_weapons.size() >= START_SLOTS:
		return null
	var weapon := WeaponInstance.new(data)
	start_weapons.append(weapon)
	return weapon


## Neue Waffe auf einen freien Run-Platz (null, wenn voll oder schon vorhanden)
func add_run_weapon(data: WeaponData) -> WeaponInstance:
	if not can_add_run_weapon() or has_weapon(data.id):
		return null
	var weapon := WeaponInstance.new(data)
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


func _process(delta: float) -> void:
	for weapon in start_weapons:
		_update_weapon(weapon, delta)
	for weapon in run_weapons:
		_update_weapon(weapon, delta)


func _update_weapon(weapon: WeaponInstance, delta: float) -> void:
	weapon.cooldown_left -= delta
	if weapon.cooldown_left > 0.0 or not player or not enemy_manager or not projectiles:
		return
	var origin := player.global_position
	# NEAREST ist der einzige umgesetzte Zielmodus, FACING und weitere folgen mit der ersten Waffe, die sie braucht
	var target := enemy_manager.find_nearest(origin, weapon.get_stat(&"range"))
	if target == -1:
		# Kein Ziel in Reichweite: Die Waffe bleibt schussbereit
		weapon.cooldown_left = 0.0
		return
	weapon.data.behavior.fire(weapon, origin, enemy_manager.get_enemy_position(target), projectiles)
	weapon.cooldown_left = weapon.get_stat(&"cooldown")
