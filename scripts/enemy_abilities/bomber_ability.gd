class_name BomberAbility
extends EnemyAbility
## Platzen (Pestbringer): Erreicht der Gegner den Helden, bleibt er stehen und bläht sich sichtbar auf (Sonder-Pose, wird größer
## und blinkt giftgrün), dann platzt er. Wird er vorher getötet, platzt er ebenfalls. Die Giftwolke trifft den Helden und
## alle Gegner im Radius (auch andere Pestbringer: Kettenreaktionen sind möglich).

## Ab dieser Entfernung (Fuß zu Fuß) beginnt das Aufblähen
@export var trigger_range := 28.0
## Dauer des Aufblähens (Warnung)
@export var swell_time := 0.6
## So viel größer wird er beim Aufblähen (0.3 = 30 %)
@export var swell_growth := 0.3
## Blinkfarbe beim Aufblähen und wie oft pro Sekunde
@export var flash_color := Color(0.6, 1.6, 0.4)
@export var flash_rate := 10.0
## Giftwolke: Radius, Schaden am Helden und an Gegnern, Effekt
@export var burst_radius := 40.0
@export var burst_damage := 20.0
@export var burst_enemy_damage := 60.0
@export var burst_effect: EffectData


func update(m: EnemyManager, i: int, data: EnemyData, target: Player, delta: float) -> bool:
	if not target:
		return false
	match m.ability_state[i]:
		STATE_CHASE:
			if m.get_enemy_position(i).distance_to(target.global_position) <= trigger_range:
				m.set_ability_state(i, STATE_WINDUP)
				return true
			return false
		STATE_WINDUP:
			m.ability_time[i] += delta
			var progress := clampf(m.ability_time[i] / swell_time, 0.0, 1.0)
			var frames := m.pose_frame_count(data, EnemyManager.POSE_SPECIAL)
			m.set_pose(i, EnemyManager.POSE_SPECIAL, mini(int(progress * frames), frames - 1))
			var blink := int(m.ability_time[i] * flash_rate) % 2 == 0
			m.set_pose_fx(i, 1.0 + swell_growth * progress, flash_color if blink else Color.WHITE)
			if progress >= 1.0:
				m.kill_now(i)
			return true
	return false


func on_death(m: EnemyManager, i: int, _data: EnemyData) -> void:
	var pos := m.get_enemy_position(i)
	if m.target:
		var reach := burst_radius + m.target.body_radius
		if pos.distance_squared_to(m.target.global_position) <= reach * reach:
			m.target.take_damage(burst_damage * m.damage_multiplier)
	m.damage_in_radius(pos, burst_radius, burst_enemy_damage, Elements.POISON)
	if m.effect_manager and burst_effect:
		m.effect_manager.play(burst_effect, pos)
