class_name WeaponContext
extends RefCounted
## Alle Verweise, die eine Waffe zum Angreifen braucht, an einer Stelle. So ändern neue Angriffsarten keine Funktionssignaturen.
## Der WeaponHolder legt es einmal an und reicht es an alle Behaviors weiter.

var player: Player
var enemy_manager: EnemyManager
var projectiles: ProjectileManager
## Zeichnet die Auren um den Helden
var auras: AuraDrawer
## Einschläge mit Flug, Zünder und Warnfläche (Blitze, Bomben)
var strikes: StrikeManager


## Sichtbarer Bereich der Welt (für Zufallspunkte im Bild).
func view_rect() -> Rect2:
	var viewport := player.get_viewport()
	return viewport.get_canvas_transform().affine_inverse() * viewport.get_visible_rect()
