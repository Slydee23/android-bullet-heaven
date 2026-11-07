class_name Player
extends Node2D
## Spielfigur: Bewegung (Touch-Joystick, am PC zusätzlich Tastatur) und Animation.

## Breite eines Animationsframes im Spritesheet (Pixel)
const FRAME_WIDTH := 16
const ANIMATION_FPS := 8.0

const IDLE_TEXTURE := preload("res://assets/sprites/characters/hero_idle.png")
const RUN_TEXTURE := preload("res://assets/sprites/characters/hero_run.png")

## Laufgeschwindigkeit in Welt-Pixeln pro Sekunde
@export var speed := 90.0

## Bereich, den der Spieler nicht verlassen kann (setzt die Run-Szene)
var bounds := Rect2()
## Touch-Joystick (setzt die Run-Szene)
var joystick: TouchJoystick

var _current_texture: Texture2D
var _animation_time := 0.0

@onready var sprite: Sprite2D = $Sprite2D


func _process(delta: float) -> void:
	var direction := _read_input()
	position += direction * speed * delta
	if bounds.has_area():
		position = position.clamp(bounds.position, bounds.end)
	if direction.x != 0.0:
		sprite.flip_h = direction.x < 0.0
	_animate(delta, direction != Vector2.ZERO)


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
