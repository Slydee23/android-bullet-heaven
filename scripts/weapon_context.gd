class_name WeaponContext
extends RefCounted
## Alle Verweise, die eine Waffe zum Angreifen braucht, an einer Stelle. So ändern neue Angriffsarten keine Funktionssignaturen.
## Der WeaponHolder legt es einmal an und reicht es an alle Behaviors weiter.

var player: Player
var enemy_manager: EnemyManager
var projectiles: ProjectileManager


## Sichtbarer Bereich der Welt (für Zufallspunkte im Bild).
func view_rect() -> Rect2:
	var viewport := player.get_viewport()
	return viewport.get_canvas_transform().affine_inverse() * viewport.get_visible_rect()
