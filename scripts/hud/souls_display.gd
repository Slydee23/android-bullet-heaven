class_name SoulsDisplay
extends HBoxContainer
## Seelen-Zähler im HUD (Symbol und Zahl): zählt bei jedem Kill mit. Ausgegeben werden die Seelen auf dem Rastplatz.

@onready var count_label: Label = $CountLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func bind_hud(_player: Player, run_state: RunState, _weapons: WeaponHolder) -> void:
	run_state.souls_changed.connect(_on_souls_changed)
	_on_souls_changed(run_state.souls)


func _on_souls_changed(souls: int) -> void:
	count_label.text = str(souls)
