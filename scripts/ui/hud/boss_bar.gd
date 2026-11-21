class_name BossBar
extends VBoxContainer
## Lebensleiste des Bosses oben in der Bildmitte mit seinem Namen. Unsichtbar, solange kein Boss lebt.
## Lauscht auf EnemyManager.boss_health_changed (die Spiel-Systeme kennen das HUD nicht).

@onready var name_label: Label = $NameLabel
@onready var bar: HudBar = $Bar


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Verbindet die Leiste mit den Gegnern (ruft HudRoot einmal beim Start auf)
func bind_enemies(enemies: EnemyManager) -> void:
	enemies.boss_health_changed.connect(_on_boss_health_changed)


func _on_boss_health_changed(data: EnemyData, hp: float, max_hp: float) -> void:
	if not data or hp <= 0.0:
		visible = false
		return
	visible = true
	name_label.text = tr(data.name_key)
	bar.ratio = hp / maxf(max_hp, 1.0)
