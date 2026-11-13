class_name OrbitBehavior
extends WeaponBehavior
## Angriffsart „kreisende Klingen“ (wie die Bibel in Vampire Survivors):
## - Zu Beginn jedes Zyklus (`cooldown`) erscheinen `amount` Klingen, gleichmäßig verteilt, und kreisen `duration` Sekunden
##   im Abstand `range` um den Helden. Danach verschwinden sie bis zum nächsten Zyklus.
## - Ist `duration` so lang wie der Zyklus (durch Upgrades), bleiben sie dauerhaft und werden beim Zyklus nicht neu erzeugt.
## - Jede Klinge trifft alle Gegner, die sie streift, denselben Gegner höchstens alle `hit_interval` Sekunden.
## Die Klingen sind Geschosse mit Bewegungsart ORBIT im ProjectileManager.

const ORBIT_STATS: Array[StringName] = [&"amount", &"duration", &"orbit_speed", &"projectile_radius", &"hit_interval"]


func fire(weapon: WeaponInstance, context: WeaponContext) -> bool:
	if context.projectiles.count_of(weapon) == 0:
		_spawn_blades(weapon, context, context.projectiles.orbit_phase(weapon))
	weapon.active_left = weapon.get_stat(&"duration")
	return true


func tick(weapon: WeaponInstance, context: WeaponContext, delta: float) -> void:
	if weapon.active_left <= 0.0:
		return
	weapon.active_left -= delta
	if weapon.active_left <= 0.0 and not is_permanent(weapon):
		context.projectiles.remove_weapon(weapon)


## Neue Werte (z. B. eine Klinge mehr): Sind gerade Klingen zu sehen, werden sie mit der neuen Anzahl neu verteilt.
func on_stats_changed(weapon: WeaponInstance, context: WeaponContext) -> void:
	if context.projectiles.count_of(weapon) == 0:
		return
	var phase := context.projectiles.orbit_phase(weapon)
	context.projectiles.remove_weapon(weapon)
	_spawn_blades(weapon, context, phase)


func _spawn_blades(weapon: WeaponInstance, context: WeaponContext, phase: float) -> void:
	var amount := maxi(1, roundi(weapon.get_stat(&"amount")))
	for k in amount:
		context.projectiles.spawn_orbit(weapon, phase + TAU * k / amount)


func is_permanent(weapon: WeaponInstance) -> bool:
	return weapon.get_stat(&"duration") >= weapon.get_stat(&"cooldown")


## Die Wirkdauer kann nie länger als der Zyklus sein: Dann sind die Klingen dauerhaft da.
func limit_stat(weapon: WeaponInstance, stat: StringName, value: float) -> float:
	if stat == &"duration":
		return minf(value, weapon.get_stat(&"cooldown"))
	return value


func card_stats() -> Array[StringName]:
	return [&"damage", &"amount", &"duration"]


func stat_label_key(stat: StringName, default_key: String) -> String:
	match stat:
		&"amount":
			return "STAT_BLADES"
		&"cooldown":
			return "STAT_CYCLE"
	return default_key


func cooldown_as_rate() -> bool:
	return false


func supports_stat(stat: StringName) -> bool:
	return stat in ORBIT_STATS or super(stat)
