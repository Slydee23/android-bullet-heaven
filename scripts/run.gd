extends Node2D
## Run-Szene: baut die Wald-Arena auf und richtet Spieler und Kamera ein.

const TILE_SIZE := 16
const PROP_SIZE := 32
## Arena-Größe in Kacheln (60×40 Kacheln = 960×640 Welt-Pixel)
const ARENA_TILES := Vector2i(60, 40)
## Anteil der Bodenkacheln mit der ersten (häufigsten) Variante
const MAIN_GROUND_SHARE := 0.7

const GROUND_TEXTURE := preload("res://assets/tiles/forest_ground.png")
const PROPS_TEXTURE := preload("res://assets/tiles/forest_props.png")
const PAUSE_MENU := preload("res://ui/pause_menu.tscn")

var _pause_menu: Control

@onready var ground: TileMapLayer = $Ground
@onready var props: Node2D = $Props
@onready var player: Player = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var joystick: TouchJoystick = $HUD/TouchJoystick
@onready var hud: CanvasLayer = $HUD
@onready var pause_button: TextureButton = $HUD/PauseButton


func _ready() -> void:
	var arena := Rect2(Vector2.ZERO, Vector2(ARENA_TILES * TILE_SIZE))
	_build_ground()
	_build_border(arena)

	# Der Spieler bleibt innerhalb des Baumrings
	player.bounds = arena.grow(-PROP_SIZE)
	player.position = arena.get_center()
	player.joystick = joystick

	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(arena.size.x)
	camera.limit_bottom = int(arena.size.y)
	camera.call_deferred("reset_smoothing")

	pause_button.pressed.connect(open_pause_menu)


func _unhandled_input(event: InputEvent) -> void:
	# Esc am PC bzw. Zurück-Geste am Handy öffnet die Pause
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		open_pause_menu()


func open_pause_menu() -> void:
	if _pause_menu:
		return
	_pause_menu = PAUSE_MENU.instantiate()
	_pause_menu.tree_exited.connect(func() -> void: _pause_menu = null)
	hud.add_child(_pause_menu)


func _build_ground() -> void:
	# Erste Reihe des Tilesets = Bodenvarianten
	var source := TileSetAtlasSource.new()
	source.texture = GROUND_TEXTURE
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var variants := int(GROUND_TEXTURE.get_width() / float(TILE_SIZE))
	for x in variants:
		source.create_tile(Vector2i(x, 0))

	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var source_id := tile_set.add_source(source)
	ground.tile_set = tile_set

	for y in ARENA_TILES.y:
		for x in ARENA_TILES.x:
			var variant := 0
			if variants > 1 and randf() > MAIN_GROUND_SHARE:
				variant = randi_range(1, variants - 1)
			ground.set_cell(Vector2i(x, y), source_id, Vector2i(variant, 0))


func _build_border(arena: Rect2) -> void:
	# Ring aus zufälligen Bäumen, Felsen und Büschen am Arenarand
	var cells := int(PROPS_TEXTURE.get_width() / float(PROP_SIZE))
	var right := int(arena.size.x) - PROP_SIZE
	var bottom := int(arena.size.y) - PROP_SIZE
	for x in range(0, right + 1, PROP_SIZE):
		_add_prop(Vector2(x, 0), cells)
		_add_prop(Vector2(x, bottom), cells)
	for y in range(PROP_SIZE, bottom, PROP_SIZE):
		_add_prop(Vector2(0, y), cells)
		_add_prop(Vector2(right, y), cells)


func _add_prop(pos: Vector2, cells: int) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = PROPS_TEXTURE
	sprite.hframes = cells
	sprite.frame = randi() % cells
	sprite.centered = false
	sprite.position = pos
	props.add_child(sprite)
