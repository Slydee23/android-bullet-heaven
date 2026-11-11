class_name WeaponBehavior
extends Resource
## Basis für Angriffsarten („wie greift die Waffe an“): Geschoss, kreisende Klinge, Aura …
## Neue Angriffsart = neues Skript, das von dieser Klasse erbt. Viele Waffen können dieselbe Angriffsart nutzen.


## Löst einen Angriff aus. from = Position des Helden (Füße), target = Position des Ziels (Füße).
func fire(_weapon: WeaponInstance, _from: Vector2, _target: Vector2, _projectiles: ProjectileManager) -> void:
	pass
