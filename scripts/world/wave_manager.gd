class_name WaveManager
extends Node
## Steuert den Ablauf einer Expedition: 20 Wellen nacheinander (Daten in WaveSet), jede mit Timer, Spawns und Ereignissen.
## Wellenende: Gegner zerfallen ohne Erfahrung, liegende Seelensplitter fliegen zum Helden (der Held ist dabei geschützt),
## dann ruft die Run-Szene den Rastplatz. Die letzte Welle endet mit dem Tod des Bosses oder nach Ablauf der Zeit: Sieg.
## Der Spiel-Ablauf liegt hier, Anzeigen lauschen auf die Signale (Spiel-Systeme kennen das HUD nicht).

## Eine Welle beginnt (Nummer ab 1)
signal wave_started(number: int, total: int, duration: float)
## Die verbleibenden ganzen Sekunden der Welle haben sich geändert
signal time_changed(seconds_left: int)
## Kurze Warnung vor einem Ereignis oder Boss (Übersetzungsschlüssel)
signal event_warning(text_key: String)
## Die Welle ist vorbei, Gegner sind zerfallen und Splitter eingesammelt: Zeit für den Rastplatz
signal cleanup_finished(number: int)
## Die Expedition ist gewonnen (boss_defeated = der Boss wurde besiegt, sonst die Zeit überstanden)
signal run_won(boss_defeated: bool)

enum State { IDLE, WAVE, CLEANUP, REST }

## So viele Sekunden vor einem Ereignis erscheint die Warnung
const EVENT_WARNING_LEAD := 1.8
## Ereignisse, die später als so viele Sekunden vor Wellenende liegen würden, entfallen
const EVENT_END_MARGIN := 3.0
## In so vielen Sekunden zerfallen alle übrigen Gegner am Wellenende
const CLEANUP_VANISH_TIME := 0.8
## Spätestens dann ist das Aufräumen beendet (falls ein Splitter hängt)
const CLEANUP_MAX_TIME := 6.0
## Ein paar Gegner stehen gleich zu Wellenbeginn bereit (höchstens so viele)
const START_BURST := 10

var wave_set: WaveSet
var enemy_manager: EnemyManager
var pickups: PickupManager
var hostile_projectiles: HostileProjectileManager
var player: Player
var run_state: RunState

var number := 0
var state := State.IDLE
var current: WaveData
## Debug: Timer und Spawns anhalten
var frozen := false

var _time_left := 0.0
var _elapsed := 0.0
var _budget := 0.0
var _event_at := PackedFloat32Array()
var _event_warned := PackedByteArray()
var _shown_seconds := -1
var _cleanup_time := 0.0
var _winning := false
var _boss_defeated := false
var _kills_at_start := 0
var _xp_at_start := 0
var _time_at_start := 0.0


func total() -> int:
	return wave_set.waves.size() if wave_set else 0


## Verbindet den Manager mit den Gegnern (einmal beim Start der Run-Szene)
func setup() -> void:
	enemy_manager.boss_health_changed.connect(_on_boss_health_changed)


## Beginnt mit Welle 1
func start() -> void:
	run_state.wave_total = total()
	_start_wave(1)


## Fortsetzen eines gespeicherten Runs: Welle n beginnt von vorn
func start_at(n: int) -> void:
	run_state.wave_total = total()
	_start_wave(n)


## Fortsetzen auf dem Rastplatz nach Welle n (die Run-Szene öffnet den Rastplatz selbst)
func resume_rest(n: int) -> void:
	run_state.wave_total = total()
	number = clampi(n, 1, total())
	current = wave_set.waves[number - 1]
	run_state.wave = number
	state = State.REST
	player.shielded = true


## Der Rastplatz ist vorbei: nächste Welle
func next_wave() -> void:
	_start_wave(number + 1)


## Dauer der nächsten Welle (für die Vorschau im Rastplatz), 0 wenn es keine gibt
func next_duration() -> float:
	return wave_set.waves[number].duration if number < total() else 0.0


func next_is_boss() -> bool:
	return number < total() and wave_set.waves[number].boss != null


## Zusammenfassung der gerade beendeten Welle für den Rastplatz
func summary() -> Dictionary:
	return {
		"wave": number,
		"total": total(),
		"kills": run_state.kills - _kills_at_start,
		"xp": run_state.xp_gained - _xp_at_start,
		"wave_time": run_state.time - _time_at_start,
		"run_time": run_state.time,
		"next_duration": next_duration(),
		"next_boss": next_is_boss(),
	}


## Faktor für die Erfahrung je Gegner in der laufenden Welle
func xp_factor() -> float:
	return current.xp_factor * wave_set.xp_scale if current else 1.0


## Faktor für die Seelen je Kill (Regler des WaveSet)
func soul_factor() -> float:
	return wave_set.soul_scale


## Höchstzahl gleichzeitiger Gegner der laufenden Welle mit dem Mengen-Regler des WaveSet
func _max_alive() -> int:
	return maxi(1, roundi(current.max_alive * wave_set.enemy_amount_scale))


func _start_wave(n: int) -> void:
	n = clampi(n, 1, total())
	number = n
	current = wave_set.waves[n - 1]
	state = State.WAVE
	_time_left = current.duration
	_elapsed = 0.0
	_budget = float(mini(START_BURST, _max_alive()))
	_shown_seconds = -1
	_winning = false
	_event_at.resize(current.events.size())
	_event_warned.resize(current.events.size())
	for k in current.events.size():
		_event_at[k] = current.events[k].first_delay
		_event_warned[k] = 0
	enemy_manager.wave_hp_factor = wave_set.hp_factor_for(n, current)
	enemy_manager.damage_multiplier = wave_set.damage_factor_for(n, current)
	player.shielded = false
	run_state.wave = n
	_kills_at_start = run_state.kills
	_xp_at_start = run_state.xp_gained
	_time_at_start = run_state.time
	if current.boss:
		enemy_manager.spawn(current.boss, enemy_manager.find_spawn_position())
		event_warning.emit("WAVE_BOSS")
	wave_started.emit(n, total(), current.duration)


func _process(delta: float) -> void:
	match state:
		State.WAVE:
			_process_wave(delta)
		State.CLEANUP:
			_process_cleanup(delta)


func _process_wave(delta: float) -> void:
	if frozen:
		return
	run_state.time += delta
	_time_left -= delta
	_elapsed += delta
	var seconds := ceili(maxf(_time_left, 0.0))
	if seconds != _shown_seconds:
		_shown_seconds = seconds
		time_changed.emit(seconds)
	# Normale Spawns: gleichmäßig nach spawn_rate, solange noch Platz unter max_alive ist
	var max_alive := _max_alive()
	_budget = minf(_budget + current.spawn_rate * wave_set.enemy_amount_scale * delta, float(max_alive))
	while _budget >= 1.0 and enemy_manager.count < max_alive:
		_budget -= 1.0
		_spawn_regular()
	_process_events()
	if _time_left <= 0.0:
		_begin_cleanup(number >= total(), false)


func _process_events() -> void:
	for k in current.events.size():
		var event := current.events[k]
		var fire_at := _event_at[k]
		if fire_at > current.duration - EVENT_END_MARGIN:
			continue
		if not _event_warned[k] and _elapsed >= fire_at - EVENT_WARNING_LEAD:
			_event_warned[k] = 1
			event_warning.emit("WAVE_EVENT_RING" if event.pattern == WaveEvent.Pattern.RING else "WAVE_EVENT_RUSH")
		if _elapsed >= fire_at:
			_fire_event(event)
			_event_at[k] = fire_at + event.interval if event.interval > 0.0 else INF
			_event_warned[k] = 0


func _fire_event(event: WaveEvent) -> void:
	if event.pattern == WaveEvent.Pattern.RING:
		enemy_manager.spawn_around(event.enemy, player.global_position, event.count)
	else:
		enemy_manager.spawn_rush(event.enemy, player.global_position, event.count)


## Zufälliger Gegnertyp der Welle nach Gewicht, an einem Punkt knapp außerhalb des Bildes
func _spawn_regular() -> void:
	var total_weight := 0.0
	for entry in current.spawns:
		total_weight += entry.weight
	if total_weight <= 0.0:
		return
	var pick := randf() * total_weight
	var chosen: EnemyData = current.spawns[current.spawns.size() - 1].enemy
	for entry in current.spawns:
		if pick < entry.weight:
			chosen = entry.enemy
			break
		pick -= entry.weight
	enemy_manager.spawn(chosen, enemy_manager.find_spawn_position())


## Wellenende: Spawns stoppen, der Held ist geschützt, Gegner zerfallen, Splitter fliegen zum Helden
func _begin_cleanup(win: bool, boss_defeated: bool) -> void:
	state = State.CLEANUP
	_cleanup_time = 0.0
	_winning = win
	_boss_defeated = boss_defeated
	player.shielded = true
	if hostile_projectiles:
		hostile_projectiles.remove_all()
	pickups.attract_all()
	time_changed.emit(0)


func _process_cleanup(delta: float) -> void:
	_cleanup_time += delta
	enemy_manager.dissolve(ceili(enemy_manager.count * delta / CLEANUP_VANISH_TIME) + 2)
	if pickups.count > 0:
		pickups.attract_all()
	var done := enemy_manager.count == 0 and pickups.count == 0 and _cleanup_time > 0.5
	if done or _cleanup_time > CLEANUP_MAX_TIME:
		enemy_manager.dissolve(enemy_manager.count)
		state = State.REST
		if _winning:
			run_won.emit(_boss_defeated)
		else:
			cleanup_finished.emit(number)


func _on_boss_health_changed(data: EnemyData, hp: float, _max_hp: float) -> void:
	# Fällt der Boss der Boss-Welle, ist die Expedition gewonnen
	if state == State.WAVE and data != null and hp <= 0.0 and current and data == current.boss:
		_begin_cleanup(true, true)


## --- Debug ---

## Beendet die laufende Welle sofort (wie abgelaufene Zeit)
func debug_end_wave() -> void:
	if state == State.WAVE:
		_time_left = 0.0
		frozen = false


## Springt zu Welle n (alle Gegner verschwinden)
func debug_jump_to(n: int) -> void:
	enemy_manager.dissolve(enemy_manager.count)
	if hostile_projectiles:
		hostile_projectiles.remove_all()
	frozen = false
	_start_wave(n)
