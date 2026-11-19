class_name RangedAbility
extends EnemyAbility
## Fernzauber (Feuer-Kultist): Der Gegner kommt nur bis auf Abstand heran, bleibt stehen, zaubert sichtbar (Angriffsstreifen)
## und wirft im Wurf-Moment ein langsames Geschoss gerade auf die Stelle, an der der Held gerade steht. Es zielt nicht nach,
## man kann ihm also ausweichen. Geschosse fliegt der HostileProjectileManager.

## Ab dieser Entfernung (Fuß zu Fuß) zaubert er, wenn die Abklingzeit vorbei ist
@export var cast_range := 160.0
## Näher als hier kommt er nicht heran: Er bleibt stehen und wartet auf den nächsten Zauber
@export var keep_distance := 110.0
## Dauer des Zaubers (ganzer Angriffsstreifen) und der Moment, in dem das Geschoss losfliegt (Anteil 0..1)
@export var cast_time := 0.8
@export var release_share := 0.8
## Zeit zwischen zwei Zaubern
@export var cooldown := 2.6

## Das Geschoss: Grafik (Streifen), Tempo, Schaden, Trefferradius, Lebensdauer und Einschlag
@export var shot_texture: Texture2D
@export var shot_frame_width := 24
@export var shot_fps := 12.0
@export var shot_speed := 85.0
@export var shot_damage := 10.0
@export var shot_radius := 6.0
@export var shot_lifetime := 4.0
@export var impact_effect: EffectData


func update(m: EnemyManager, i: int, data: EnemyData, target: Player, delta: float) -> bool:
	m.ability_timer[i] = maxf(m.ability_timer[i] - delta, 0.0)
	if not target:
		return false
	var pos := m.get_enemy_position(i)
	var hero := target.global_position
	var distance := pos.distance_to(hero)
	match m.ability_state[i]:
		STATE_CHASE:
			if m.ability_timer[i] <= 0.0 and distance <= cast_range:
				m.set_ability_state(i, STATE_WINDUP)
				m.face(i, pos.direction_to(hero))
				return true
			if distance <= keep_distance:
				# Auf Abstand stehen bleiben und den Helden ansehen
				m.face(i, pos.direction_to(hero))
				m.set_pose(i, EnemyManager.POSE_WALK, 0)
				return true
			m.set_pose(i, EnemyManager.POSE_WALK, -1)
			return false
		STATE_WINDUP:
			var before := m.ability_time[i]
			m.ability_time[i] += delta
			var frames := m.pose_frame_count(data, EnemyManager.POSE_ATTACK)
			m.set_pose(i, EnemyManager.POSE_ATTACK, mini(int(m.ability_time[i] / cast_time * frames), frames - 1))
			var release := cast_time * release_share
			if before < release and m.ability_time[i] >= release and m.hostile_projectiles:
				var direction := pos.direction_to(hero)
				m.face(i, direction)
				m.hostile_projectiles.spawn(self, pos + direction * 8.0, direction, shot_damage * m.damage_multiplier)
			if m.ability_time[i] >= cast_time:
				m.set_ability_state(i, STATE_CHASE)
				m.ability_timer[i] = cooldown
				m.set_pose(i, EnemyManager.POSE_WALK, -1)
			return true
	return false
