class_name AuraBehavior
extends WeaponBehavior
## Angriffsart „Aura“: eine Dauerfläche um den Helden (Flammenfackel). Alle `cooldown` Sekunden ein Schadens-Puls
## auf alle Gegner im Radius `range`. Der AuraDrawer zeichnet die Fläche (Flammenring).
## Radius und Takt sind die Werte, die Upgrades (M6) verbessern, beide mit Grenzen in WeaponData.stat_limits.

## Flammenmantel direkt am Helden (Streifen, Blick egal): Teil hinter dem Helden und Teil davor (Funken).
## Versatz = obere linke Ecke eines Frames relativ zu den Füßen des Helden (aus dem PixelLab-Export, manifest.json).
@export var mantle_behind: Texture2D
@export var mantle_behind_frame := Vector2i(32, 50)
@export var mantle_behind_offset := Vector2(-16, -43)
@export var mantle_front: Texture2D
@export var mantle_front_frame := Vector2i(18, 24)
@export var mantle_front_offset := Vector2(-9, -23)
@export var mantle_fps := 10.0


func fire(weapon: WeaponInstance, context: WeaponContext) -> bool:
	var amount := weapon.get_stat(&"damage")
	weapon.total_damage += context.enemy_manager.damage_in_radius(context.player.global_position, weapon.get_stat(&"range"), amount, weapon.data.element)
	# Die Aura pulst immer weiter, auch ohne Gegner im Radius
	return true


func tick(weapon: WeaponInstance, context: WeaponContext, _delta: float) -> void:
	if not weapon.units_spawned and context.auras:
		context.auras.add(weapon, context.player)
		weapon.units_spawned = true


func on_removed(weapon: WeaponInstance, context: WeaponContext) -> void:
	if context.auras:
		context.auras.remove(weapon)
	weapon.units_spawned = false


func card_stats() -> Array[StringName]:
	return [&"damage", &"cooldown", &"range"]


func stat_label_key(stat: StringName, default_key: String) -> String:
	match stat:
		&"cooldown":
			return "STAT_HITS_PER_SECOND"
		&"range":
			return "STAT_RADIUS"
	return default_key
