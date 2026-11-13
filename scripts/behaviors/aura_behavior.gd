class_name AuraBehavior
extends WeaponBehavior
## Angriffsart „Aura“: eine Dauerfläche um den Helden (Flammenfackel). Alle `cooldown` Sekunden ein Schadens-Puls
## auf alle Gegner im Radius `range`. Der AuraDrawer zeichnet die Fläche (Flammenring).
## Radius und Takt sind die Werte, die Upgrades (M6) verbessern, beide mit Grenzen in WeaponData.stat_limits.


func fire(weapon: WeaponInstance, context: WeaponContext) -> bool:
	var amount := weapon.get_stat(&"damage")
	var hits := context.enemy_manager.damage_in_radius(context.player.global_position, weapon.get_stat(&"range"), amount, weapon.data.element)
	weapon.total_damage += hits * amount
	# Die Aura pulst immer weiter, auch ohne Gegner im Radius
	return true


func tick(weapon: WeaponInstance, context: WeaponContext, _delta: float) -> void:
	if not weapon.units_spawned and context.auras:
		context.auras.add(weapon, context.player)
		weapon.units_spawned = true


func card_stats() -> Array[StringName]:
	return [&"damage", &"cooldown", &"range"]


func stat_label_key(stat: StringName, default_key: String) -> String:
	match stat:
		&"cooldown":
			return "STAT_HITS_PER_SECOND"
		&"range":
			return "STAT_RADIUS"
	return default_key
