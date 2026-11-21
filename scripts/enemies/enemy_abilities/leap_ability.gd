class_name LeapAbility
extends EnemyAbility
## Sprungangriff (Ghul): Ist der Held nah genug, duckt sich der Gegner kurz (Warnung) und springt dann dorthin, wo der Held
## gleich sein wird (er zielt erst beim Absprung und rechnet die Laufrichtung des Helden mit ein), danach erholt er sich. Trifft er den Helden im Sprung, macht er
## Sprungschaden. Ausweichen klappt mit einem Haken: die Richtung wechseln, nachdem er abgesprungen ist.
## Pose: Angriffsstreifen (EnemyData.attack_texture), die ersten Frames beim Ducken, die restlichen im Sprung.

## Ab dieser Entfernung (Fuß zu Fuß, Welt-Pixel) setzt er zum Sprung an
@export var trigger_range := 80.0
## Ducken vor dem Sprung (Sekunden, die Warnung für den Spieler)
@export var windup := 0.3
## Dauer und Weite des Sprungs
@export var leap_time := 0.3
@export var leap_distance := 100.0
## Vorhalt: so viele Sekunden der Heldenbewegung rechnet er beim Zielen voraus (0 = zielt auf die aktuelle Position)
@export var lead_time := 0.3
## Stehen nach dem Sprung
@export var recover := 0.35
## Zeit bis zum nächsten Sprung
@export var cooldown := 2.2
## Schaden, wenn er den Helden im Sprung trifft
@export var leap_damage := 8.0
## Wie viele Frames des Angriffsstreifens zum Ducken gehören (der Rest ist der Sprung)
@export var windup_frames := 3


func update(m: EnemyManager, i: int, data: EnemyData, target: Player, delta: float) -> bool:
	m.ability_timer[i] = maxf(m.ability_timer[i] - delta, 0.0)
	var state := m.ability_state[i]
	var hero := target.global_position if target else m.get_enemy_position(i)
	match state:
		STATE_CHASE:
			if target and m.ability_timer[i] <= 0.0 and m.get_enemy_position(i).distance_to(hero) <= trigger_range:
				m.set_ability_state(i, STATE_WINDUP)
				m.ability_vec[i] = m.get_enemy_position(i).direction_to(hero)
				m.face(i, m.ability_vec[i])
				return true
			return false
		STATE_WINDUP:
			m.ability_time[i] += delta
			m.set_pose(i, EnemyManager.POSE_ATTACK, mini(int(m.ability_time[i] / windup * windup_frames), windup_frames - 1))
			if m.ability_time[i] >= windup:
				# Erst beim Absprung zielen: dorthin, wo der Held gleich sein wird
				var aim := hero + (target.velocity * lead_time if target else Vector2.ZERO)
				m.ability_vec[i] = m.get_enemy_position(i).direction_to(aim)
				m.face(i, m.ability_vec[i])
				m.set_ability_state(i, STATE_ACTION)
			return true
		STATE_ACTION:
			m.ability_time[i] += delta
			var frames := m.pose_frame_count(data, EnemyManager.POSE_ATTACK)
			var progress := clampf(m.ability_time[i] / leap_time, 0.0, 1.0)
			m.set_pose(i, EnemyManager.POSE_ATTACK, windup_frames + mini(int(progress * (frames - windup_frames)), frames - windup_frames - 1))
			m.move_enemy(i, m.ability_vec[i] * leap_distance / leap_time * delta)
			# Trifft er den Helden, endet der Sprung sofort (ein Treffer pro Sprung)
			if target:
				var reach := data.radius + target.body_radius
				if m.get_enemy_position(i).distance_squared_to(hero) <= reach * reach:
					target.take_damage(leap_damage * m.damage_multiplier)
					m.set_ability_state(i, STATE_RECOVER)
					return true
			if m.ability_time[i] >= leap_time:
				m.set_ability_state(i, STATE_RECOVER)
			return true
		STATE_RECOVER:
			m.ability_time[i] += delta
			m.set_pose(i, EnemyManager.POSE_ATTACK, m.pose_frame_count(data, EnemyManager.POSE_ATTACK) - 1)
			if m.ability_time[i] >= recover:
				m.set_ability_state(i, STATE_CHASE)
				m.ability_timer[i] = cooldown
				m.set_pose(i, EnemyManager.POSE_WALK, -1)
			return true
	return false
