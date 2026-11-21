class_name WaveDisplay
extends VBoxContainer
## Oben in der Bildmitte: „Welle 3 / 20“, darunter Restzeit und besiegte Gegner. Warnungen vor Ereignissen (Einkesselung,
## Rudel, Boss) erscheinen kurz darunter. Lauscht auf die Signale des WaveManager (die Spiel-Systeme kennen das HUD nicht).

## So lange bleibt eine Warnung sichtbar (Sekunden)
const ALERT_TIME := 2.5

var _run_state: RunState
var _alert_left := 0.0

@onready var wave_label: Label = $WaveLabel
@onready var time_label: Label = $TimeLabel
@onready var alert_label: Label = $AlertLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	alert_label.visible = false
	set_process(false)


func bind_hud(_player: Player, run_state: RunState, _weapons: WeaponHolder) -> void:
	_run_state = run_state


## Verbindet die Anzeige mit dem Wellen-Ablauf (ruft HudRoot einmal beim Start auf)
func bind_waves(waves: WaveManager) -> void:
	waves.wave_started.connect(_on_wave_started)
	waves.time_changed.connect(_on_time_changed)
	waves.event_warning.connect(_on_event_warning)


func _on_wave_started(number: int, total: int, duration: float) -> void:
	wave_label.text = tr("HUD_WAVE") % [number, total]
	_on_time_changed(ceili(duration))


func _on_time_changed(seconds_left: int) -> void:
	# Wellenende: eine noch sichtbare Warnung verschwindet
	if seconds_left <= 0:
		alert_label.visible = false
		set_process(false)
	var kills := _run_state.kills if _run_state else 0
	time_label.text = "%d:%02d · %s" % [seconds_left / 60, seconds_left % 60, tr("HUD_KILLS") % kills]


func _on_event_warning(text_key: String) -> void:
	alert_label.text = tr(text_key)
	alert_label.visible = true
	_alert_left = ALERT_TIME
	set_process(true)


func _process(delta: float) -> void:
	_alert_left -= delta
	# In der letzten halben Sekunde blinkt die Warnung schneller, dann verschwindet sie
	if _alert_left <= 0.0:
		alert_label.visible = false
		set_process(false)
	else:
		alert_label.modulate.a = 1.0 if _alert_left > 0.5 or int(_alert_left * 12.0) % 2 == 0 else 0.4
