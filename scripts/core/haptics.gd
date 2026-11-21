class_name Haptics
extends RefCounted
## Vibration für Spiel-Feedback (z. B. Treffer).
## Godots Input.vibrate_handheld meldet Vibrationen bei Android als „Berührungs-Feedback“ an. Viele Handys schalten das
## ab (Einstellung „Haptisches Feedback“), dann verwirft Android jede Spiel-Vibration. Ab Android 13 rufen wir die
## Android-Vibration deshalb direkt auf und melden sie als „Medien“ an (zählt wie Spiele und Videos).
## Überall sonst (ältere Android-Versionen, PC) gilt der normale Godot-Weg.

## Ab dieser Android-Version gibt es Vibrator.vibrate(VibrationEffect, VibrationAttributes) (API 33)
const MIN_ANDROID_VERSION := 13
## android.os.VibrationAttributes.USAGE_MEDIA
const USAGE_MEDIA := 19
## Stärke bei Android: 1..255
const MAX_AMPLITUDE := 255

static var _initialized := false
static var _vibrator: Object
static var _effect_class: Object
static var _attributes: Object


## android.os.VibrationEffect.DEFAULT_AMPLITUDE: Standard-Stärke des Handys
const DEFAULT_AMPLITUDE := -1


## duration_ms: Dauer in Millisekunden, strength: 0..1 (kleiner als 0 = Standard-Stärke des Handys)
static func vibrate(duration_ms: int, strength: float) -> void:
	if not _initialized:
		_initialize()
	if _vibrator == null:
		Input.vibrate_handheld(duration_ms, strength if strength >= 0.0 else -1.0)
		return
	var amplitude := DEFAULT_AMPLITUDE
	if strength >= 0.0:
		amplitude = clampi(roundi(strength * MAX_AMPLITUDE), 1, MAX_AMPLITUDE)
	var effect: Object = _effect_class.createOneShot(duration_ms, amplitude)
	_vibrator.vibrate(effect, _attributes)


## Holt einmalig die Android-Objekte. Klappt etwas nicht, bleibt _vibrator leer und es gilt der Godot-Weg.
static func _initialize() -> void:
	_initialized = true
	if OS.get_name() != "Android" or OS.get_version().to_int() < MIN_ANDROID_VERSION:
		return
	if not Engine.has_singleton("AndroidRuntime"):
		return
	var activity: Object = Engine.get_singleton("AndroidRuntime").getActivity()
	if activity == null:
		return
	var attributes_class: Object = JavaClassWrapper.wrap("android.os.VibrationAttributes")
	_effect_class = JavaClassWrapper.wrap("android.os.VibrationEffect")
	if attributes_class == null or _effect_class == null:
		return
	_attributes = attributes_class.createForUsage(USAGE_MEDIA)
	if _attributes == null:
		return
	_vibrator = activity.getSystemService("vibrator")
