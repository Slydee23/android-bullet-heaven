class_name BossKnightAbility
extends EnemyAbility
## Knochenritter (Boss): zwei klar angekündigte, ausweichbare Angriffe.
## - Bodenschlag: Ist der Held nah, bleibt er stehen, hebt das Schwert (Angriffsstreifen), vor ihm füllt sich eine rote
##   Warnfläche, dann schlägt er zu: Schaden in der Fläche, der Bildschirm wackelt.
## - Ansturm: Steht der Held weiter weg, duckt er sich, eine rote Warnlinie zeigt die Bahn, dann stürmt er geradeaus.
## Zwischen den Angriffen läuft er langsam auf den Helden zu. ability_timer = Abklingzeit Ansturm, ability_timer_b = Bodenschlag.

const STATE_CHARGE_WINDUP := 4
const STATE_CHARGE := 5

const WARN_FILL := Color(0.85, 0.12, 0.1, 0.12)
const WARN_PROGRESS := Color(0.85, 0.12, 0.1, 0.2)
const WARN_RIM := Color(0.95, 0.25, 0.2, 0.6)

@export_group("Bodenschlag")
## Ab dieser Entfernung (Fuß zu Fuß) setzt er zum Schlag an
@export var slam_trigger := 70.0
## So weit vor ihm liegt die Mitte der Schlagfläche, und so groß ist sie
@export var slam_offset := 30.0
@export var slam_radius := 46.0
## Ausholen (Warnung), Nachwirkung nach dem Schlag, Abklingzeit
@export var slam_windup := 0.9
@export var slam_recover := 0.6
@export var slam_cooldown := 2.5
@export var slam_damage := 30.0
## So stark wackelt der Bildschirm beim Einschlag (0..1)
@export var slam_shake := 0.8
## Ab diesem Frame des Angriffsstreifens trifft das Schwert den Boden
@export var slam_hit_frame := 6

@export_group("Ansturm")
## Ab dieser Entfernung stürmt er, wenn die Abklingzeit vorbei ist
@export var charge_min_range := 120.0
@export var charge_windup := 0.8
@export var charge_time := 0.6
@export var charge_distance := 240.0
@export var charge_recover := 0.6
@export var charge_cooldown := 7.0
@export var charge_damage := 25.0


func update(m: EnemyManager, i: int, data: EnemyData, target: Player, delta: float) -> bool:
	m.ability_timer[i] = maxf(m.ability_timer[i] - delta, 0.0)
	m.ability_timer_b[i] = maxf(m.ability_timer_b[i] - delta, 0.0)
	if not target:
		return false
	var pos := m.get_enemy_position(i)
	var hero := target.global_position
	var distance := pos.distance_to(hero)
	match m.ability_state[i]:
		STATE_CHASE:
			m.set_pose(i, EnemyManager.POSE_WALK, -1)
			if m.ability_timer_b[i] <= 0.0 and distance <= slam_trigger:
				var direction := pos.direction_to(hero)
				m.face(i, direction)
				m.ability_vec[i] = pos + direction * slam_offset
				m.set_ability_state(i, STATE_WINDUP)
				return true
			if m.ability_timer[i] <= 0.0 and distance >= charge_min_range:
				var direction := pos.direction_to(hero)
				m.face(i, direction)
				m.ability_vec[i] = direction
				m.set_ability_state(i, STATE_CHARGE_WINDUP)
				return true
			return false
		STATE_WINDUP:
			m.ability_time[i] += delta
			var progress := clampf(m.ability_time[i] / slam_windup, 0.0, 1.0)
			m.set_pose(i, EnemyManager.POSE_ATTACK, mini(int(progress * slam_hit_frame), slam_hit_frame - 1))
			if progress >= 1.0:
				_slam(m, i, target)
				m.set_ability_state(i, STATE_ACTION)
			return true
		STATE_ACTION:
			# Schwert liegt am Boden (letzte Frames), dann kurz verschnaufen
			m.ability_time[i] += delta
			var frames := m.pose_frame_count(data, EnemyManager.POSE_ATTACK)
			m.set_pose(i, EnemyManager.POSE_ATTACK, mini(slam_hit_frame + int(m.ability_time[i] * 10.0), frames - 1))
			if m.ability_time[i] >= slam_recover:
				m.ability_timer_b[i] = slam_cooldown
				m.set_ability_state(i, STATE_CHASE)
			return true
		STATE_CHARGE_WINDUP:
			m.ability_time[i] += delta
			# Anlauf: Er beugt sich Bild für Bild nach vorn (die ersten Frames der Charge-Animation)
			var lean := clampf(m.ability_time[i] / charge_windup, 0.0, 1.0)
			m.set_pose(i, EnemyManager.POSE_SPECIAL, mini(int(lean * 3.0), 2))
			if m.ability_time[i] >= charge_windup:
				m.set_ability_state(i, STATE_CHARGE)
			return true
		STATE_CHARGE:
			m.ability_time[i] += delta
			# Charge-Animation im Kreis (ab Frame 3: volle Schritte, Umhang weht)
			var charge_frames := m.pose_frame_count(data, EnemyManager.POSE_SPECIAL)
			m.set_pose(i, EnemyManager.POSE_SPECIAL, 3 + int(m.ability_time[i] * 14.0) % maxi(charge_frames - 3, 1))
			# Rennt er gegen ein Hindernis, endet der Ansturm dort (Deckung für den Helden)
			if m.move_enemy(i, m.ability_vec[i] * charge_distance / charge_time * delta):
				m.screen_shake.emit(slam_shake * 0.5)
				m.set_ability_state(i, STATE_RECOVER)
				return true
			var reach := data.radius + target.body_radius
			if m.get_enemy_position(i).distance_squared_to(hero) <= reach * reach:
				target.take_damage(charge_damage * m.damage_multiplier)
			if m.ability_time[i] >= charge_time:
				m.set_ability_state(i, STATE_RECOVER)
			return true
		STATE_RECOVER:
			m.ability_time[i] += delta
			m.set_pose(i, EnemyManager.POSE_WALK, 0)
			m.set_pose_fx(i, 1.0, Color.WHITE)
			if m.ability_time[i] >= charge_recover:
				m.ability_timer[i] = charge_cooldown
				m.set_ability_state(i, STATE_CHASE)
			return true
	return false


func _slam(m: EnemyManager, i: int, target: Player) -> void:
	var center := m.ability_vec[i]
	var reach := slam_radius + target.body_radius
	if center.distance_squared_to(target.global_position) <= reach * reach:
		target.take_damage(slam_damage * m.damage_multiplier)
	m.screen_shake.emit(slam_shake)


## Warnflächen am Boden (zeichnet der EnemyManager vor den Gegnern)
func draw_ground(m: EnemyManager, i: int, data: EnemyData, canvas: CanvasItem) -> void:
	match m.ability_state[i]:
		STATE_WINDUP:
			var center := m.ability_vec[i]
			var progress := clampf(m.ability_time[i] / slam_windup, 0.0, 1.0)
			canvas.draw_circle(center, slam_radius, WARN_FILL)
			canvas.draw_circle(center, slam_radius * progress, WARN_PROGRESS)
			canvas.draw_arc(center, slam_radius, 0.0, TAU, 48, WARN_RIM, 1.5)
		STATE_CHARGE_WINDUP:
			var progress := clampf(m.ability_time[i] / charge_windup, 0.0, 1.0)
			var direction := m.ability_vec[i]
			var start := m.get_enemy_position(i)
			canvas.draw_set_transform(start, direction.angle())
			var lane := Rect2(0.0, -data.radius, charge_distance, data.radius * 2.0)
			canvas.draw_rect(lane, WARN_FILL)
			canvas.draw_rect(Rect2(lane.position, Vector2(lane.size.x * progress, lane.size.y)), WARN_PROGRESS)
			canvas.draw_rect(lane, WARN_RIM, false, 1.5)
			canvas.draw_set_transform(Vector2.ZERO)
