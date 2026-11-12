class_name ProjectileBehavior
extends WeaponBehavior
## Angriffsart „Geschoss“: Pro Angriff fliegen `amount` Geschosse auf die Ziele des TargetPickers zu.
## - Jedes Geschoss bekommt ein eigenes Ziel (nächster, zweitnächster …) und startet gleichzeitig.
## - Gibt es mehr Geschosse als Ziele, folgen die überzähligen als Salve (SALVO_DELAY Sekunden Abstand),
##   reihum auf die schon gewählten Ziele. Es gibt keinen Fächer und keine Zufallsrichtungen.

## Abstand der Salven-Geschosse in Sekunden
const SALVO_DELAY := 0.1
const PROJECTILE_STATS: Array[StringName] = [
	&"amount", &"pierce", &"projectile_speed", &"projectile_radius", &"projectile_lifetime",
]

## Arbeitsspeicher für die Zielplätze (gilt nur innerhalb eines fire()-Aufrufs, deshalb darf er geteilt sein)
var _targets := PackedInt32Array()


func fire(weapon: WeaponInstance, context: WeaponContext) -> bool:
	var amount := maxi(1, roundi(weapon.get_stat(&"amount")))
	var origin := context.player.global_position
	var found := weapon.target_picker.pick(origin, weapon.get_stat(&"range"), amount, context, _targets)
	if found == 0:
		return false
	var enemies := context.enemy_manager
	for k in found:
		context.projectiles.spawn(weapon, origin, origin.direction_to(enemies.get_enemy_position(_targets[k])))
	for j in range(found, amount):
		var k := (j - found) % found
		context.projectiles.schedule(weapon, enemies.get_id(_targets[k]), SALVO_DELAY * (j - found + 1))
	return true


func card_stats() -> Array[StringName]:
	return [&"damage", &"cooldown", &"amount"]


func supports_stat(stat: StringName) -> bool:
	return stat in PROJECTILE_STATS or super(stat)
