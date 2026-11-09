extends Node2D
## Run-Szene: baut die Wald-Arena auf und richtet Spieler und Kamera ein.

const TILE_SIZE := 32
const PROP_SIZE := 64
## Arena-Größe in Kacheln (40×28 Kacheln = 1280×896 Welt-Pixel)
const ARENA_TILES := Vector2i(40, 28)
## Anteil der Bodenkacheln mit der ersten (häufigsten) Variante
const MAIN_GROUND_SHARE := 0.7

const GROUND_TEXTURE := preload("res://assets/tiles/forest_ground.png")
const PROPS_TEXTURE := preload("res://assets/tiles/forest_props.png")
const PAUSE_MENU := preload("res://ui/pause_menu.tscn")
const DEBUG_MENU := preload("res://ui/debug_menu.tscn")
const GAME_OVER_MENU := preload("res://ui/game_over_menu.tscn")
const SKELETON := preload("res://data/enemies/skeleton.tres")
## Ab so vielen lebenden Gegnern ist der dynamische Zoom ganz draußen (M3: = MAX_ALIVE, ab M7 aus den Wellen-Daten)
const ZOOM_FULL_ENEMIES := 60
## Wie oft die FPS-Anzeige aktualisiert wird (Sekunden)
const FPS_UPDATE_INTERVAL := 0.5

var _pause_menu: Control
var _debug_menu: DebugMenu
var _game_over := false
var _fps_timer := 0.0

@onready var ground: TileMapLayer = $Ground
@onready var props: Node2D = $Props
@onready var player: Player = $Player
@onready var camera: RunCamera = $Player/Camera2D
@onready var joystick: TouchJoystick = $HUD/TouchJoystick
@onready var hud: CanvasLayer = $HUD
@onready var pause_button: TextureButton = $HUD/PauseButton
@onready var debug_button: TextureButton = $HUD/DebugButton
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var fps_label: Label = $HUD/FpsLabel


func _ready() -> void:
	var arena := Rect2(Vector2.ZERO, Vector2(ARENA_TILES * TILE_SIZE))
	_build_ground()
	_build_border(arena)

	# Der Spieler bleibt innerhalb des Baumrings
	player.bounds = arena.grow(-PROP_SIZE)
	player.position = arena.get_center()
	player.joystick = joystick
	player.died.connect(_on_player_died)

	enemy_manager.set_bounds(player.bounds)
	enemy_manager.target = player
	enemy_manager.spawn_types = [SKELETON]

	# FPS-Anzeige nur in Test-Builds (aus Godot gestartet), nicht in einer späteren Veröffentlichung
	fps_label.visible = OS.is_debug_build()

	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(arena.size.x)
	camera.limit_bottom = int(arena.size.y)
	_apply_zoom()
	camera.snap_zoom()
	Settings.changed.connect(_on_settings_changed)
	camera.call_deferred("reset_smoothing")

	pause_button.pressed.connect(open_pause_menu)
	# Debug-Menü nur in Test-Builds, nicht in einer späteren Veröffentlichung
	debug_button.visible = OS.is_debug_build()
	debug_button.pressed.connect(_toggle_debug_menu)


func _process(delta: float) -> void:
	camera.pressure = enemy_manager.count / float(ZOOM_FULL_ENEMIES)
	if not fps_label.visible:
		return
	_fps_timer -= delta
	if _fps_timer <= 0.0:
		_fps_timer = FPS_UPDATE_INTERVAL
		fps_label.text = tr("DEBUG_FPS") % [Engine.get_frames_per_second(), enemy_manager.count]


func _unhandled_input(event: InputEvent) -> void:
	# Esc am PC bzw. Zurück-Geste am Handy öffnet die Pause
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		open_pause_menu()


func _notification(what: int) -> void:
	# Auto-Pause: App geht in den Hintergrund (Android) oder das Fenster verliert den Fokus (PC, Benachrichtigungsleiste)
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		open_pause_menu()


func open_pause_menu() -> void:
	if _pause_menu or _game_over:
		return
	_pause_menu = PAUSE_MENU.instantiate()
	_pause_menu.tree_exited.connect(_on_pause_menu_closed)
	hud.add_child(_pause_menu)


func _on_player_died() -> void:
	_game_over = true
	# Das Pausemenü kann hier nicht offen sein: Bei Pause greift niemand an
	hud.add_child(GAME_OVER_MENU.instantiate())


func _on_pause_menu_closed() -> void:
	_pause_menu = null
	_update_pause()


func _toggle_debug_menu() -> void:
	if _debug_menu:
		_debug_menu.queue_free()
		return
	_debug_menu = DEBUG_MENU.instantiate()
	_debug_menu.player = player
	_debug_menu.tree_exited.connect(_on_debug_menu_closed)
	hud.add_child(_debug_menu)
	_update_pause()


func _on_debug_menu_closed() -> void:
	_debug_menu = null
	_update_pause()


## Das Spiel steht bei Game Over, solange die Pause offen ist oder das Debug-Menü offen ist und nicht weiterlaufen soll.
func _update_pause() -> void:
	# Beim Verlassen des Runs schließen sich die Menüs mit, dann gibt es hier nichts mehr zu steuern
	if not is_inside_tree():
		return
	get_tree().paused = _game_over or _pause_menu != null or (_debug_menu != null and not Settings.debug_keep_running)


func _on_settings_changed() -> void:
	_apply_zoom()
	_update_pause()


## Zoom-Testmodus aus dem Debug-Menü übernehmen (Spawn-Abstand passt sich über das sichtbare Rechteck von selbst an)
func _apply_zoom() -> void:
	camera.dynamic = Settings.camera_zoom_mode == Settings.CameraZoomMode.DYNAMIC
	if Settings.camera_zoom_mode == Settings.CameraZoomMode.FAR:
		camera.fixed_zoom = RunCamera.ZOOM_FAR
	else:
		camera.fixed_zoom = RunCamera.ZOOM_NEAR


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
