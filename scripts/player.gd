class_name Player
extends Node2D
## Spielfigur: Bewegung (Touch-Joystick, am PC zusätzlich Tastatur), Animation und Lebenspunkte.
## Waffen gehören bewusst nicht hierher: Derselbe Held läuft später auch waffenlos durch die Stadt.
## Die Position des Nodes sind die Füße (Low Top-Down): Dort sitzt auch der Kollisionskreis.

signal died

## Breite eines Animationsframes im Spritesheet (Pixel)
const FRAME_WIDTH := 16
const ANIMATION_FPS := 8.0
## Wie schnell der Held während der Unverwundbarkeit blinkt (Sekunden pro Phase)
const BLINK_INTERVAL := 0.08
## So lange leuchtet der Held nach einem Treffer rot auf (Sekunden)
const HIT_FLASH_TIME := 0.1
const HIT_FLASH_COLOR := Color(1.0, 0.35, 0.35)

const IDLE_TEXTURE := preload("res://assets/sprites/characters/hero_idle.png")
const RUN_TEXTURE := preload("res://assets/sprites/characters/hero_run.png")

## Laufgeschwindigkeit in Welt-Pixeln pro Sekunde
@export var speed := 90.0
@export var max_hp := 100.0
## Körperradius in Welt-Pixeln um die Füße: Bis hierhin kommen Gegner heran
@export var body_radius := 5.0

## Bereich, den der Spieler nicht verlassen kann (setzt die Run-Szene)
var bounds := Rect2()
## Touch-Joystick (setzt die Run-Szene)
var joystick: TouchJoystick
var hp := max_hp

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
	_apply_settings()
	Settings.changed.connect(_apply_settings)


## Zieht Lebenspunkte ab. Gibt false zurück, wenn der Treffer nicht zählt (unverwundbar oder schon tot).
func take_damage(amount: float) -> bool:
	if hp <= 0.0 or _invulnerable_left > 0.0:
		return false
	hp = maxf(hp - amount, 0.0)
	health_bar.value = hp
	_hit_flash_left = HIT_FLASH_TIME
	if Settings.debug_hit_invulnerability:
		_invulnerable_left = Settings.debug_invulnerability_duration
	if hp <= 0.0:
		died.emit()
	return true


func _apply_settings() -> void:
	health_bar.visible = Settings.show_player_health_bar


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
