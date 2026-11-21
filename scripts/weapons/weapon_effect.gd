class_name WeaponEffect
extends Resource
## Basis für Waffen-Effekte (z. B. Ricochet, Brennen, Explosion). Ein Effekt greift nur bei Ereignissen ein,
## nicht pro Frame. Neuer Effekt = neues Skript, das von dieser Klasse erbt, und ein Eintrag in `effects` der Waffe.
## Vorhanden: ApplyStatusEffect (Status bei Treffer). Noch keiner Waffe zugeordnet (M4g: Status nur per Debug).


## Ein Geschoss der Waffe hat Gegner enemy_index an der Stelle position getroffen.
func on_hit(_weapon: WeaponInstance, _position: Vector2, _enemy_index: int, _projectiles: ProjectileManager) -> void:
	pass
