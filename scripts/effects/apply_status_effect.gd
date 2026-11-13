class_name ApplyStatusEffect
extends WeaponEffect
## Waffen-Effekt: Ein Treffer setzt mit `chance` den Status `status` auf den getroffenen Gegner
## (z. B. später: Fackel und Bomben setzen Brennen, Dreizack Schock). In M4g noch keiner Waffe zugeordnet.

@export var status: StatusEffectData
## Wahrscheinlichkeit pro Treffer (1 = immer)
@export_range(0.0, 1.0) var chance := 1.0


func on_hit(_weapon: WeaponInstance, _position: Vector2, enemy_index: int, projectiles: ProjectileManager) -> void:
	if status and projectiles.enemy_manager and randf() < chance:
		projectiles.enemy_manager.apply_status(enemy_index, status)
