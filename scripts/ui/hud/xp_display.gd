class_name XpDisplay
extends Control
## XP-Leiste unten mittig, rechts darin die Stufe des Helden („Lv 7“).

@onready var bar: HudBar = $Bar
@onready var level_label: Label = $LevelLabel


## Verbindet die Anzeige mit dem Run (ruft HudRoot einmal beim Start auf)
func bind_hud(_player: Player, run_state: RunState, _weapons: WeaponHolder) -> void:
	run_state.xp_changed.connect(_on_xp_changed)
	run_state.leveled_up.connect(_on_leveled_up)
	_on_xp_changed(run_state.xp, run_state.xp_needed())
	_on_leveled_up(run_state.level)


func _on_xp_changed(xp: int, needed: int) -> void:
	bar.ratio = xp / float(maxi(needed, 1))


func _on_leveled_up(level: int) -> void:
	level_label.text = tr("HUD_LEVEL") % level
