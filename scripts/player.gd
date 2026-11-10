class_name Player
extends Node2D
## Spielfigur: Bewegung (Touch-Joystick, am PC zusätzlich Tastatur), Animation und Lebenspunkte.
## Waffen gehören bewusst nicht hierher: Derselbe Held läuft später auch waffenlos durch die Stadt.
## Die Position des Nodes sind die Füße (Low Top-Down): Dort sitzt auch der Kollisionskreis.

signal died
## Ein Treffer hat gezählt (nicht bei Selbstschaden). Die Run-Szene löst damit Wackeln und Vibration aus.
signal damaged(amount: float)

## Breite eines Animationsframes im Spritesheet (Pixel)
const FRAME_WIDTH := 32
const ANIMATION_FPS := 8.0
## Wie schnell der Held während der Unverwundbarkeit blinkt (Sekunden pro Phase)
const BLINK_INTERVAL := 0.08
## So lange leuchtet der Held nach einem Treffer rot auf (Sekunden)
const HIT_FLASH_TIME := 0.1
const HIT_FLASH_COLOR := Color(1.0, 0.35, 0.35)
## Selbstschaden tötet vorläufig nicht: So viele HP bleiben mindestens übrig (endgültig entschieden wird beim ersten Effekt)
const SELF_DAMAGE_MIN_HP := 1.0

const IDLE_TEXTURE := preload("res://assets/sprites/characters/hero_idle.png")
const RUN_TEXTURE := preload("res://assets/sprites/characters/hero_run.png")

## Laufgeschwindigkeit in Welt-Pixeln pro Sekunde
@export var speed := 120.0
@export var max_hp := 100.0
## Körperradius in Welt-Pixeln um die Füße: Bis hierhin kommen Gegner heran
@export var body_radius := 10.0
## Wie lange der Held nach einem Treffer unverwundbar ist
@export var base_iframe_rule: IFrameRule

## Bereich, den der Spieler nicht verlassen kann (setzt die Run-Szene)
var bounds := Rect2()
## Touch-Joystick (setzt die Run-Szene)
var joystick: TouchJoystick
var hp := max_hp
## Geltende Regel: Kopie von base_iframe_rule, in Test-Builds mit den Werten aus dem Debug-Menü
var iframe_rule: IFrameRule
## Dauer der letzten I-Frames in Sekunden (Anzeige im Debug-Menü)
var last_iframe_duration := 0.0

var _current_texture: Texture2D
var _animation_time := 0.0
var _invulnerable_left := 0.0
var _hit_flash_left := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: TextureProgressBar = $HealthBar


func _ready() -> void:
	hp = max_hp
	health_bar.max_value = max_hp
	health_bar.value = hp
	iframe_rule = base_iframe_rule.duplicate()
	_apply_settings()
	Settings.changed.connect(_apply_settings)


## Treffer von außen: Zieht Lebenspunkte ab und startet die I-Frames.
## Gibt false zurück, wenn der Treffer nicht zählt (unverwundbar oder schon tot).
func take_damage(amount: float) -> bool:
	if hp <= 0.0 or _invulnerable_left > 0.0:
		return false
	last_iframe_duration = iframe_rule.duration_for(amount, max_hp)
	_invulnerable_left = last_iframe_duration
	_hit_flash_left = HIT_FLASH_TIME
	_set_hp(maxf(hp - amount, 0.0))
	damaged.emit(amount)
	if hp <= 0.0:
		died.emit()
	return true


## Selbstschaden (z. B. durch Boni): Wirkt auch während der I-Frames und löst selbst keine aus.
func take_self_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	_set_hp(maxf(hp - amount, minf(hp, SELF_DAMAGE_MIN_HP)))


func _set_hp(value: float) -> void:
	hp = value
	health_bar.value = hp


func _apply_settings() -> void:
	health_bar.visible = Settings.show_player_health_bar
	iframe_rule.min_duration = base_iframe_rule.min_duration
	iframe_rule.max_duration = base_iframe_rule.max_duration
	iframe_rule.reference_share = base_iframe_rule.reference_share
	# Testwerte aus dem Debug-Menü gelten nur in Test-Builds
	if OS.is_debug_build() and Settings.has_debug_iframes():
		iframe_rule.min_duration = Settings.debug_iframe_min
		iframe_rule.max_duration = Settings.debug_iframe_max
		iframe_rule.reference_share = Settings.debug_iframe_share


func _process(delta: float) -> void:
	_update_hit_feedback(delta)
	var direction := _read_input()
	position += direction * speed * delta
	if bounds.has_area():
		position = position.clamp(bounds.position, bounds.end)
	if direction.x != 0.0:
		sprite.flip_h = direction.x < 0.0
	_animate(delta, direction != Vector2.ZERO)


func _update_hit_feedback(delta: float) -> void:
	_hit_flash_left = maxf(_hit_flash_left - delta, 0.0)
	_invulnerable_left = maxf(_invulnerable_left - delta, 0.0)
	sprite.modulate = HIT_FLASH_COLOR if _hit_flash_left > 0.0 else Color.WHITE
	sprite.visible = _invulnerable_left <= 0.0 or int(_invulnerable_left / BLINK_INTERVAL) % 2 == 0


func _read_input() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if direction == Vector2.ZERO and joystick:
		return joystick.output
	return direction.normalized()


func _animate(delta: float, moving: bool) -> void:
	var texture: Texture2D = RUN_TEXTURE if moving else IDLE_TEXTURE
	if texture != _current_texture:
		# Frame-Anzahl ergibt sich aus der Bildbreite, so passen auch Alpha-Assets mit mehr Frames
		_current_texture = texture
		sprite.frame = 0
		sprite.texture = texture
		sprite.hframes = maxi(1, int(texture.get_width() / float(FRAME_WIDTH)))
		_animation_time = 0.0
	_animation_time += delta
	sprite.frame = int(_animation_time * ANIMATION_FPS) % sprite.hframes
