class_name StrikeManager
extends Node2D
## Verwaltet alle Einschläge zentral (Blitze des Dreizacks, Bomben des Bombenbeutels), wie der ProjectileManager:
## Werte in Arrays, ein Pool, ein Zeichenaufruf. Ein Einschlag fliegt optional im Bogen vom Helden zum Ziel (flight),
## liegt dann mit Warnfläche eine Zündzeit lang (fuse) und löst danach aus: Schaden im Wirkradius `area`, Effekt abspielen.
## Ohne Flug und Zünder (Blitz) löst er sofort aus und wird gar nicht erst gespeichert.
## Liegt in der Run-Szene vor dem EnemyManager: Warnflächen und Bomben liegen am Boden unter den Gegnern.

const MAX_STRIKES := 256
## Wie hoch eine geworfene Bombe in der Mitte des Flugs ist (Welt-Pixel)
const ARC_HEIGHT := 28.0
## Die Bombe liegt mit ihrer Unterkante auf dem Boden: so weit über dem Zielpunkt wird ihre Bildmitte gezeichnet
const BOMB_LIFT := 6.0
## Warnfläche: dezent rot, füllt sich bis zur Explosion von innen, mit etwas kräftigerem Rand
const WARN_FILL := Color(0.85, 0.12, 0.1, 0.10)
const WARN_PROGRESS := Color(0.85, 0.12, 0.1, 0.16)
const WARN_RIM := Color(0.95, 0.25, 0.2, 0.55)
const WARN_RIM_WIDTH := 1.5
## Ab diesem Anteil der Zündzeit blinkt die Bombe, immer schneller (Wechsel pro Sekunde am Anfang und am Ende)
const BLINK_SHARE := 0.6
const BLINK_SLOW := 4.0
const BLINK_FAST := 16.0

## Gegner, die getroffen werden, und Effekte beim Auslösen (setzt die Run-Szene)
var enemy_manager: EnemyManager
var effect_manager: EffectManager
var count := 0

var _from := PackedVector2Array()
var _to := PackedVector2Array()
var _age := PackedFloat32Array()
var _flight := PackedFloat32Array()
var _fuse := PackedFloat32Array()
var _weapon_index := PackedInt32Array()
## 1 = Effekt schon gestartet (StrikeBehavior.effect_lead), beim Auslösen nicht noch einmal abspielen
var _effect_played := PackedByteArray()
var _weapons: Array[WeaponInstance] = []
var _was_drawn := false


func _ready() -> void:
	_from.resize(MAX_STRIKES)
	_to.resize(MAX_STRIKES)
	_age.resize(MAX_STRIKES)
	_flight.resize(MAX_STRIKES)
	_fuse.resize(MAX_STRIKES)
	_weapon_index.resize(MAX_STRIKES)
	_effect_played.resize(MAX_STRIKES)


## Neuer Einschlag der Waffe: fliegt flight Sekunden von from nach to, liegt dann fuse Sekunden und löst aus.
## Ohne Flug und Zünder löst er sofort aus. Ist der Pool voll, entfällt der Einschlag.
func launch(weapon: WeaponInstance, from: Vector2, to: Vector2, flight: float, fuse: float) -> void:
	var behavior := weapon.data.behavior as StrikeBehavior
	var lead := behavior.effect_lead if behavior else 0.0
	if flight <= 0.0 and fuse <= 0.0 and lead <= 0.0:
		_detonate(weapon, to, true)
		return
	# Der Effekt braucht Vorlauf: der Einschlag wartet so lange (ohne Bild, ohne Warnfläche)
	if flight <= 0.0 and fuse <= 0.0:
		flight = lead
	if count >= MAX_STRIKES:
		return
	var slot := _weapons.find(weapon)
	if slot == -1:
		_weapons.append(weapon)
		slot = _weapons.size() - 1
	_from[count] = from
	_to[count] = to
	_age[count] = 0.0
	_flight[count] = flight
	_fuse[count] = fuse
	_weapon_index[count] = slot
	_effect_played[count] = 0
	count += 1


## Entfernt alle wartenden Einschläge dieser Waffe (z. B. wenn die Waffe abgelegt wird)
func remove_weapon(weapon: WeaponInstance) -> void:
	var slot := _weapons.find(weapon)
	if slot == -1:
		return
	for i in range(count - 1, -1, -1):
		if _weapon_index[i] == slot:
			_remove(i)


func _remove(i: int) -> void:
	count -= 1
	_from[i] = _from[count]
	_to[i] = _to[count]
	_age[i] = _age[count]
	_flight[i] = _flight[count]
	_fuse[i] = _fuse[count]
	_weapon_index[i] = _weapon_index[count]
	_effect_played[i] = _effect_played[count]


## Schaden im Wirkradius (Werte zum Zeitpunkt der Explosion), Schadenszähler der Waffe und Effekt
func _detonate(weapon: WeaponInstance, at: Vector2, with_effect: bool) -> void:
	var amount := weapon.get_stat(&"damage")
	if enemy_manager:
		weapon.total_damage += enemy_manager.damage_in_radius(at, weapon.get_stat(&"area"), amount, weapon.data.element)
	if with_effect:
		_play_effect(weapon, at)


## Effekt des Einschlags, bei Bedarf so vergrößert, dass er den aktuellen Wirkradius zeigt (StrikeBehavior.effect_area_reference)
func _play_effect(weapon: WeaponInstance, at: Vector2) -> void:
	var behavior := weapon.data.behavior as StrikeBehavior
	if not effect_manager or not behavior:
		return
	if behavior.effect:
		effect_manager.play(behavior.effect, at)
	if behavior.impact_effect:
		var impact_scale := 1.0
		if behavior.effect_area_reference > 0.0:
			impact_scale = weapon.get_stat(&"area") / behavior.effect_area_reference
		effect_manager.play(behavior.impact_effect, at, 0.0, Vector2(impact_scale, impact_scale))


func _process(delta: float) -> void:
	# Rückwärts, weil _remove() den letzten Einschlag auf den freien Platz setzt
	for i in range(count - 1, -1, -1):
		_age[i] += delta
		var weapon := _weapons[_weapon_index[i]]
		var behavior := weapon.data.behavior as StrikeBehavior
		var lead := behavior.effect_lead if behavior else 0.0
		var total := _flight[i] + _fuse[i]
		if lead > 0.0 and not _effect_played[i] and _age[i] >= total - lead:
			_effect_played[i] = 1
			_play_effect(weapon, _to[i])
		if _age[i] >= total:
			var at := _to[i]
			var played := _effect_played[i] == 1
			_remove(i)
			_detonate(weapon, at, not played)
	# Nur neu zeichnen, solange etwas läuft (und einmal danach, um das letzte Bild zu löschen)
	if count > 0 or _was_drawn:
		queue_redraw()


func _draw() -> void:
	_was_drawn = count > 0
	for i in count:
		var weapon := _weapons[_weapon_index[i]]
		var age := _age[i]
		var landed := age >= _flight[i]
		# Warnfläche ab der Landung: genau so groß wie die Explosion, füllt sich bis zum Auslösen
		if landed and _fuse[i] > 0.0:
			var radius := weapon.get_stat(&"area")
			var progress := clampf((age - _flight[i]) / _fuse[i], 0.0, 1.0)
			draw_circle(_to[i], radius, WARN_FILL)
			draw_circle(_to[i], radius * progress, WARN_PROGRESS)
			draw_arc(_to[i], radius, 0.0, TAU, 48, WARN_RIM, WARN_RIM_WIDTH)
		var texture := weapon.data.projectile_texture
		if not texture:
			continue
		var pos := _to[i]
		if not landed:
			# Bogenwurf: gerade Linie am Boden, dazu eine Parabel nach oben
			var t := age / _flight[i]
			pos = _from[i].lerp(_to[i], t) - Vector2(0.0, ARC_HEIGHT * 4.0 * t * (1.0 - t))
		var frame_width := weapon.data.frame_width
		var frames := maxi(1, int(texture.get_width() / float(frame_width)))
		var frame := 0
		var left := _flight[i] + _fuse[i] - age
		if landed and frames > 1 and left < _fuse[i] * BLINK_SHARE:
			# Kurz vor der Explosion: immer schneller zwischen normal und aufblitzend wechseln
			var urgency := 1.0 - left / (_fuse[i] * BLINK_SHARE)
			frame = int(age * lerpf(BLINK_SLOW, BLINK_FAST, urgency)) % 2
		var size := Vector2(frame_width, texture.get_height())
		var top_left := (pos - Vector2(0.0, BOMB_LIFT) - size * 0.5).round()
		draw_texture_rect_region(texture, Rect2(top_left, size), Rect2(Vector2(frame * frame_width, 0), size))
