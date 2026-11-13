class_name HealthDisplay
extends HBoxContainer
## Feste Lebensleiste oben links: Herz, Leiste und „80 / 100“.
## (Die kleine Leiste über dem Helden bleibt zusätzlich und ist in den Optionen abschaltbar.)

@onready var bar: HudBar = $Bar
@onready var hp_label: Label = $HpLabel


func bind_hud(player: Player, _run_state: RunState, _weapons: WeaponHolder) -> void:
	player.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(player.hp, player.max_hp)


func _on_hp_changed(hp: float, max_hp: float) -> void:
	bar.ratio = hp / maxf(max_hp, 1.0)
	hp_label.text = "%d / %d" % [ceili(hp), roundi(max_hp)]
