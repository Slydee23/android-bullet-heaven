class_name WeaponEffect
extends Resource
## Basis für Waffen-Effekte (z. B. Ricochet, Brennen, Explosion). Ein Effekt greift nur bei Ereignissen ein,
## nicht pro Frame. Neuer Effekt = neues Skript, das von dieser Klasse erbt, und ein Eintrag in `effects` der Waffe.
## In M4 gibt es noch keinen konkreten Effekt, der Anschluss steht aber.


## Ein Geschoss der Waffe hat Gegner enemy_index an der Stelle position getroffen.
func on_hit(_weapon: WeaponInstance, _position: Vector2, _enemy_index: int, _projectiles: ProjectileManager) -> void:
	pass
