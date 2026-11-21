class_name HudRoot
extends Control
## Wurzel der festen HUD-Anzeigen (siehe PLAN.md „UI-Konzepte → HUD“). Jede Anzeige ist eine eigene kleine Szene in ui/hud/
## mit einer Funktion bind_hud(player, run_state, weapons). Spiel-Systeme kennen das HUD nicht: Die Anzeigen lauschen auf Signale.
## Keine Einrückung für die Kamera-Notch (Safe Area): Auf dem Testhandy liegt die Kamera im Querformat links auf halber Höhe,
## wo kein HUD steht, und eingerückt wirkte alles zu weit im Bild (getestet in M6a). Braucht ein Gerät das später doch,
## gehört es nur hierher.

const PixelUI := preload("res://scripts/ui/pixel_ui.gd")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = PixelUI.make_theme()


## Verbindet alle Anzeigen mit dem Run (ruft die Run-Szene einmal beim Start auf)
func bind(player: Player, run_state: RunState, weapons: WeaponHolder, enemies: EnemyManager = null, waves: WaveManager = null) -> void:
	for node in find_children("*", "Control", true, false):
		if node.has_method("bind_hud"):
			node.bind_hud(player, run_state, weapons)
		# Anzeigen, die Gegner brauchen (z. B. die Boss-Leiste), haben bind_enemies
		if enemies and node.has_method("bind_enemies"):
			node.bind_enemies(enemies)
		# Die Wellen-Anzeige braucht den Wellen-Ablauf
		if waves and node.has_method("bind_waves"):
			node.bind_waves(waves)
