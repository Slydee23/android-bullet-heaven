class_name ProjectileBehavior
extends WeaponBehavior
## Angriffsart „Geschoss“: Ein Geschoss fliegt in gerader Linie auf das Ziel zu.


func fire(weapon: WeaponInstance, from: Vector2, target: Vector2, projectiles: ProjectileManager) -> void:
	projectiles.spawn(weapon, from, from.direction_to(target))
