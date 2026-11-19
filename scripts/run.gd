extends Node2D
## Run-Szene: baut die Wald-Arena auf und richtet Spieler und Kamera ein.

const TILE_SIZE := 32
## Begehbare Fläche in Kacheln (36×24 Kacheln = 1152×768 Welt-Pixel)
const WALKABLE_TILES := Vector2i(36, 24)
## Dichter Wald rund um die begehbare Fläche (Kacheln je Seite)
const FOREST_TILES := 5
## Anteil der begehbaren Kacheln mit einem zufälligen Bodendetail (Steine, Laub, Pilze …)
const GROUND_DETAIL_SHARE := 0.1

## Waldrand-Stücke in forest_edge.png: je 32×32, Fußpunkt unten in der Mitte
const EDGE_PIECE_SIZE := 32
const EDGE_CROWNS := Vector2i(0, 3)
const EDGE_BUSHES := Vector2i(4, 5)
const EDGE_TREES := Vector2i(6, 7)
const EDGE_SHADOW := 8

## Boden und Kronendach sind nahtlose Muster aus mehreren Kacheln (Wiederholung erst nach der ganzen Bildgröße)
const GROUND_TEXTURE := preload("res://assets/tiles/forest_ground.png")
const GROUND_DETAILS_TEXTURE := preload("res://assets/tiles/forest_ground_details.png")
const CANOPY_TEXTURE := preload("res://assets/tiles/forest_canopy.png")
const FOREST_EDGE_TEXTURE := preload("res://assets/tiles/forest_edge.png")
const PAUSE_MENU := preload("res://ui/pause_menu.tscn")
const DEBUG_MENU := preload("res://ui/debug_menu.tscn")
const GAME_OVER_MENU := preload("res://ui/game_over_menu.tscn")
const SKELETON := preload("res://data/enemies/skeleton.tres")
const HIT_EFFECT := preload("res://data/effects/hit.tres")
const DEATH_EFFECT := preload("res://data/effects/death.tres")
const XP_CURVE := preload("res://data/progression/xp_curve.tres")
const LEVEL_UP_MENU := preload("res://ui/level_up_menu.tscn")
const WEAPON_CATALOG := preload("res://data/weapons/weapon_catalog.tres")
const HERO_UPGRADES := preload("res://data/upgrades/hero_upgrades.tres")
## Startwaffe des Runs (vorerst fest, die Auswahl im Hub kommt mit E10). Datei: data/weapons/<id>.tres
const START_WEAPON_ID := &"arcane_wand"
## Ab so vielen lebenden Gegnern ist der dynamische Zoom ganz draußen (darüber wird es nur voller).
## Bewusst fest und nicht von den Waves abhängig: Ab 50 Gegnern ist der Bildschirm voll genug für den weitesten Zoom.
const ZOOM_FULL_ENEMIES := 50
## Wie oft die FPS-Anzeige aktualisiert wird (Sekunden)
const FPS_UPDATE_INTERVAL := 0.5
## So viele letzte Bildzeiten fließen in die Leistungsanzeige ein (bei 60 FPS etwa 2 Sekunden)
const FRAME_SAMPLES := 120
## Treffer-Feedback: Mindeststärke (kleine Treffer) und wie stark der Trefferanteil an max_hp dazukommt
## (5 % Treffer → 0,43 leicht, 20 % Treffer → 0,95 kräftig)
const HIT_FEEDBACK_MIN := 0.25
const HIT_FEEDBACK_PER_SHARE := 3.5
## Vibrationsdauer in Millisekunden für schwache bzw. stärkste Treffer
const VIBRATION_MIN_MS := 40
const VIBRATION_MAX_MS := 120
## Vibrationsstärke 0..1 für schwache bzw. stärkste Treffer (nur Handys, die die Stärke regeln können).
## -1 = Standard-Stärke des Handys. Zum Vergleich getestet: 0,7 bis 1,0 bei 60–150 ms.
const VIBRATION_MIN_AMPLITUDE := -1.0
const VIBRATION_MAX_AMPLITUDE := -1.0

## Zustand, der nur in diesem Run gilt (Stufe, Erfahrung), getrennt vom dauerhaften Spielstand
var run_state := RunState.new(XP_CURVE)
## Würfelt und verteilt die Level-Up-Karten
var level_up_pool := LevelUpPool.new()
var _level_up_menu: LevelUpMenu
## Stufenaufstiege, deren Fenster noch kommt (mehrere auf einmal erscheinen nacheinander)
var _pending_level_ups := 0
var _pause_menu: Control
var _debug_menu: DebugMenu
## Der Held ist gestorben (sperrt die Pause), auch schon während der Tod-Animation
var _game_over := false
var _game_over_menu: Control
var _fps_timer := 0.0
## Ringpuffer der letzten Bildzeiten (Sekunden) für Durchschnitt und langsamstes Bild
var _frame_times := PackedFloat32Array()
var _frame_index := 0

@onready var ground: TileMapLayer = $Ground
@onready var ground_details: TileMapLayer = $GroundDetails
@onready var canopy: TileMapLayer = $Canopy
@onready var forest_edge: Node2D = $ForestEdge
@onready var forest_edge_front: Node2D = $ForestEdgeFront
@onready var player: Player = $Player
@onready var camera: RunCamera = $Player/Camera2D
@onready var joystick: TouchJoystick = $HUD/TouchJoystick
@onready var hud: CanvasLayer = $HUD
@onready var pause_button: TextureButton = $HUD/HudRoot/PauseButton
@onready var debug_button: TextureButton = $HUD/HudRoot/DebugButton
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var projectile_manager: ProjectileManager = $ProjectileManager
@onready var weapon_holder: WeaponHolder = $Weapons
@onready var effect_manager: EffectManager = $EffectManager
@onready var aura_drawer: AuraDrawer = $AuraDrawer
@onready var strike_manager: StrikeManager = $StrikeManager
@onready var damage_numbers: DamageNumberManager = $DamageNumbersLayer/DamageNumbers
@onready var fps_label: Label = $HUD/HudRoot/FpsLabel
@onready var hud_root: HudRoot = $HUD/HudRoot
@onready var pickup_manager: PickupManager = $PickupManager
@onready var hostile_projectiles: HostileProjectileManager = $HostileProjectiles


func _ready() -> void:
	var arena_tiles := WALKABLE_TILES + Vector2i.ONE * FOREST_TILES * 2
	var arena := Rect2(Vector2.ZERO, Vector2(arena_tiles * TILE_SIZE))
	var walkable := Rect2(Vector2.ONE * FOREST_TILES * TILE_SIZE, Vector2(WALKABLE_TILES * TILE_SIZE))
	_build_ground(arena_tiles)
	_build_canopy(arena_tiles)
	_build_forest_edge(walkable)

	# Der Spieler bleibt innerhalb des Waldes
	player.bounds = walkable
	player.position = walkable.get_center()
	player.joystick = joystick
	player.died.connect(_on_player_died)
	player.death_animation_finished.connect(_on_death_animation_finished)
	player.damaged.connect(_on_player_damaged)

	enemy_manager.set_bounds(player.bounds)
	enemy_manager.target = player
	enemy_manager.spawn_types = [SKELETON]
	enemy_manager.enemy_damaged.connect(_on_enemy_damaged)
	enemy_manager.enemy_killed.connect(_on_enemy_killed)
	pickup_manager.target = player
	hostile_projectiles.target = player
	hostile_projectiles.effect_manager = effect_manager
	hostile_projectiles.bounds = player.bounds
	enemy_manager.hostile_projectiles = hostile_projectiles
	enemy_manager.effect_manager = effect_manager
	pickup_manager.collected.connect(run_state.add_xp)

	projectile_manager.enemy_manager = enemy_manager
	projectile_manager.bounds = player.bounds
	projectile_manager.shooter = player
	strike_manager.enemy_manager = enemy_manager
	strike_manager.effect_manager = effect_manager
	player.set_stats(run_state.stats)
	weapon_holder.global_stats = run_state.stats
	weapon_holder.setup(player, enemy_manager, projectile_manager, aura_drawer, strike_manager, effect_manager)
	var start_weapon: WeaponData = load("res://data/weapons/%s.tres" % START_WEAPON_ID)
	weapon_holder.add_start_weapon(start_weapon)
	hud_root.bind(player, run_state, weapon_holder)
	level_up_pool.catalog = WEAPON_CATALOG
	level_up_pool.hero_pool = HERO_UPGRADES
	level_up_pool.weapons = weapon_holder
	level_up_pool.run_state = run_state
	level_up_pool.player = player
	run_state.leveled_up.connect(_on_leveled_up)

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
	if _frame_times.is_empty():
		_frame_times.resize(FRAME_SAMPLES)
	_frame_times[_frame_index] = delta
	_frame_index = (_frame_index + 1) % FRAME_SAMPLES
	_fps_timer -= delta
	if _fps_timer <= 0.0:
		_fps_timer = FPS_UPDATE_INTERVAL
		_update_fps_label()


## Leistungsanzeige (nur Test-Builds): FPS, durchschnittliche und längste Bildzeit der letzten ~2 s in Millisekunden
## (die längste zeigt Ruckler, die der FPS-Wert verschluckt), dazu Gegner, Geschosse und Effekte.
func _update_fps_label() -> void:
	var total := 0.0
	var longest := 0.0
	for t in _frame_times:
		total += t
		longest = maxf(longest, t)
	var average := total / FRAME_SAMPLES
	fps_label.text = tr("DEBUG_FPS") % [Engine.get_frames_per_second(), average * 1000.0, longest * 1000.0,
			enemy_manager.count, projectile_manager.count + strike_manager.count, effect_manager.count, pickup_manager.count]


func _unhandled_input(event: InputEvent) -> void:
	# Esc am PC bzw. Zurück-Geste am Handy öffnet die Pause
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		open_pause_menu()


func _notification(what: int) -> void:
	# Auto-Pause: App geht in den Hintergrund (Android) oder das Fenster verliert den Fokus (PC, Benachrichtigungsleiste)
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		open_pause_menu()


## Stufenaufstieg: Karten erst nach dem laufenden Frame zeigen (add_xp kann mehrere Stufen auf einmal bringen)
func _on_leveled_up(_level: int) -> void:
	_pending_level_ups += 1
	call_deferred("_show_next_level_up")


func _show_next_level_up() -> void:
	if _level_up_menu or _pending_level_ups <= 0 or _game_over or player.hp <= 0.0 or not is_inside_tree():
		return
	_pending_level_ups -= 1
	var menu: LevelUpMenu = LEVEL_UP_MENU.instantiate()
	menu.offers = level_up_pool.roll()
	menu.level = run_state.level - _pending_level_ups
	menu.chosen.connect(_on_level_up_chosen)
	_level_up_menu = menu
	hud.add_child(menu)
	_update_pause()


func _on_level_up_chosen(offer: LevelUpOffer) -> void:
	level_up_pool.apply(offer)
	_level_up_menu.queue_free()
	_level_up_menu = null
	_update_pause()
	call_deferred("_show_next_level_up")


func open_pause_menu() -> void:
	if _pause_menu or _game_over or _level_up_menu:
		return
	var menu: PauseMenu = PAUSE_MENU.instantiate()
	menu.player = player
	menu.weapon_holder = weapon_holder
	menu.run_state = run_state
	_pause_menu = menu
	_pause_menu.tree_exited.connect(_on_pause_menu_closed)
	hud.add_child(_pause_menu)


## Der Held stirbt: Gegner frieren ein, der Held spielt seine Tod-Animation, und erst danach erscheint Game Over.
func _on_player_died() -> void:
	_game_over = true
	enemy_manager.process_mode = Node.PROCESS_MODE_DISABLED
	projectile_manager.process_mode = Node.PROCESS_MODE_DISABLED
	weapon_holder.process_mode = Node.PROCESS_MODE_DISABLED
	aura_drawer.process_mode = Node.PROCESS_MODE_DISABLED
	strike_manager.process_mode = Node.PROCESS_MODE_DISABLED
	hostile_projectiles.process_mode = Node.PROCESS_MODE_DISABLED
	joystick.visible = false
	# Das Pausemenü kann hier nicht offen sein: Bei Pause greift niemand an.
	# Das Debug-Menü (Spiel läuft weiter) würde dagegen nur stören.
	if _debug_menu:
		_debug_menu.queue_free()


## Treffer-Funken und Schadenszahl in der Körpermitte des getroffenen Gegners (Schaden über Zeit: nur eine kleine Zahl)
func _on_enemy_damaged(pos: Vector2, amount: float, element: StringName, crit: bool, kill: bool, dot: bool) -> void:
	var body := pos - Vector2(0.0, EnemyManager.BODY_HEIGHT)
	if not dot:
		effect_manager.play(HIT_EFFECT, body)
	if Settings.show_damage_numbers:
		damage_numbers.spawn(body, amount, element, crit, kill, dot)


## Tod-Staub an den Füßen des gestorbenen Gegners, dazu sein Seelensplitter
func _on_enemy_killed(pos: Vector2, data: EnemyData, flipped: bool) -> void:
	# Eigene Tod-Animation (gespiegelt wie der Gegner) oder der allgemeine Tod-Staub
	if data.death_effect:
		effect_manager.play(data.death_effect, pos, 0.0, Vector2(-1.0 if flipped else 1.0, 1.0))
	else:
		effect_manager.play(DEATH_EFFECT, pos)
	pickup_manager.spawn(pos, data.xp_value)


func _on_death_animation_finished() -> void:
	_game_over_menu = GAME_OVER_MENU.instantiate()
	hud.add_child(_game_over_menu)


## Treffer-Feedback: Bild wackeln und Handy vibrieren lassen, je nach Optionen. Große Treffer wirken stärker.
func _on_player_damaged(amount: float) -> void:
	var strength := clampf(HIT_FEEDBACK_MIN + amount / player.max_hp * HIT_FEEDBACK_PER_SHARE, HIT_FEEDBACK_MIN, 1.0)
	if Settings.screen_shake:
		camera.shake(strength)
	if Settings.vibration:
		Haptics.vibrate(roundi(lerpf(VIBRATION_MIN_MS, VIBRATION_MAX_MS, strength)),
				lerpf(VIBRATION_MIN_AMPLITUDE, VIBRATION_MAX_AMPLITUDE, strength))


func _on_pause_menu_closed() -> void:
	_pause_menu = null
	_update_pause()


func _toggle_debug_menu() -> void:
	if _debug_menu:
		_debug_menu.queue_free()
		return
	_debug_menu = DEBUG_MENU.instantiate()
	_debug_menu.player = player
	_debug_menu.weapon_holder = weapon_holder
	_debug_menu.enemy_manager = enemy_manager
	_debug_menu.run_state = run_state
	_debug_menu.pickup_manager = pickup_manager
	_debug_menu.tree_exited.connect(_on_debug_menu_closed)
	hud.add_child(_debug_menu)
	_update_pause()


func _on_debug_menu_closed() -> void:
	_debug_menu = null
	_update_pause()


## Das Spiel steht, sobald das Game-Over-Fenster offen ist, solange die Pause offen ist oder das Debug-Menü offen ist und nicht weiterlaufen soll.
func _update_pause() -> void:
	# Beim Verlassen des Runs schließen sich die Menüs mit, dann gibt es hier nichts mehr zu steuern
	if not is_inside_tree():
		return
	get_tree().paused = (_game_over_menu != null or _pause_menu != null or _level_up_menu != null
			or (_debug_menu != null and not Settings.debug_keep_running))


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


## TileSet mit allen 32×32-Kacheln eines Bildes (Quelle 0, Kachel = Spalte/Zeile im Bild).
func _make_tile_set(texture: Texture2D) -> TileSet:
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var grid := _tile_grid(texture)
	for y in grid.y:
		for x in grid.x:
			source.create_tile(Vector2i(x, y))
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_source(source)
	return tile_set


func _tile_grid(texture: Texture2D) -> Vector2i:
	# Nur ganze Kacheln zählen (Abrunden ist gewollt)
	return Vector2i((texture.get_size() / TILE_SIZE).floor())


func _is_walkable_cell(cell: Vector2i) -> bool:
	var local := cell - Vector2i.ONE * FOREST_TILES
	return local.x >= 0 and local.y >= 0 and local.x < WALKABLE_TILES.x and local.y < WALKABLE_TILES.y


## Boden als nahtloses Muster: Jede Zelle nimmt die Kachel an ihrer Position im Muster, dazu zufällige Details.
## Das Muster wird pro Run zufällig verschoben, damit jede Expedition etwas anders aussieht (Nähte bleiben korrekt).
func _build_ground(arena_tiles: Vector2i) -> void:
	ground.tile_set = _make_tile_set(GROUND_TEXTURE)
	var pattern := _tile_grid(GROUND_TEXTURE)
	var shift := Vector2i(randi() % pattern.x, randi() % pattern.y)
	ground_details.tile_set = _make_tile_set(GROUND_DETAILS_TEXTURE)
	var detail_count := _tile_grid(GROUND_DETAILS_TEXTURE).x
	for y in arena_tiles.y:
		for x in arena_tiles.x:
			var cell := Vector2i(x, y)
			ground.set_cell(cell, 0, Vector2i((x + shift.x) % pattern.x, (y + shift.y) % pattern.y))
			if _is_walkable_cell(cell) and randf() < GROUND_DETAIL_SHARE:
				ground_details.set_cell(cell, 0, Vector2i(randi() % detail_count, 0))


## Dichtes Kronendach außerhalb der begehbaren Fläche. Die Reihe direkt über ihr bleibt frei:
## Dort stehen die Stämme des oberen Waldrands (man schaut von vorne in den Wald).
func _build_canopy(arena_tiles: Vector2i) -> void:
	canopy.tile_set = _make_tile_set(CANOPY_TEXTURE)
	var pattern := _tile_grid(CANOPY_TEXTURE)
	for y in arena_tiles.y:
		for x in arena_tiles.x:
			var cell := Vector2i(x, y)
			if _is_walkable_cell(cell) or _is_walkable_cell(cell + Vector2i.DOWN):
				continue
			canopy.set_cell(cell, 0, Vector2i(x % pattern.x, y % pattern.y))


## Organischer Waldrand: Kronen, Büsche und Bäume mit zufälligem Abstand, Versatz und Spiegelung verdecken die
## geraden Kanten des Kronendachs. Unten liegen sie vor den Figuren (man läuft „hinter“ die Bäume).
## Entsteht einmal beim Start (ca. 300 Sprites mit derselben Textur, die Godot gemeinsam zeichnet).
func _build_forest_edge(walkable: Rect2) -> void:
	var back: Array[Sprite2D] = []
	var front: Array[Sprite2D] = []
	var top := walkable.position.y
	var bottom := walkable.end.y
	var left := walkable.position.x
	var right := walkable.end.x

	# Oben: Schatten unter dem Kronendach, eine Reihe Kronen, davor Bäume mit sichtbarem Stamm
	for x in range(int(left) - TILE_SIZE, int(right) + TILE_SIZE, TILE_SIZE):
		forest_edge.add_child(_edge_sprite(EDGE_SHADOW, Vector2(x + TILE_SIZE * 0.5, top), false))
	var x_pos := left - 24.0
	while x_pos < right + 24.0:
		back.append(_edge_sprite(_pick(EDGE_CROWNS), Vector2(x_pos, top - 14.0 + randi_range(-4, 4)), randf() < 0.5))
		x_pos += randi_range(16, 22)
	x_pos = left - 16.0
	while x_pos < right + 16.0:
		back.append(_edge_sprite(_pick(EDGE_TREES), Vector2(x_pos, top + randi_range(0, 3)), randf() < 0.5))
		x_pos += randi_range(17, 24)

	# Links und rechts: Kronen, die leicht in die Fläche ragen, dazu einzelne weiter außen
	var y_pos := top - 8.0
	while y_pos < bottom + 24.0:
		back.append(_edge_sprite(_pick(EDGE_CROWNS), Vector2(left - 3.0 + randi_range(-4, 3), y_pos + 16.0), randf() < 0.5))
		back.append(_edge_sprite(_pick(EDGE_CROWNS), Vector2(right + 3.0 + randi_range(-3, 4), y_pos + 16.0), randf() < 0.5))
		if randf() < 0.5:
			back.append(_edge_sprite(_pick(EDGE_CROWNS), Vector2(left - 20.0, y_pos + 8.0), randf() < 0.5))
		if randf() < 0.5:
			back.append(_edge_sprite(_pick(EDGE_CROWNS), Vector2(right + 20.0, y_pos + 8.0), randf() < 0.5))
		y_pos += randi_range(16, 20)

	# Unten: Kronen und Büsche vor den Figuren
	x_pos = left - 24.0
	while x_pos < right + 24.0:
		var bush := randf() < 0.3
		var piece := _pick(EDGE_BUSHES) if bush else _pick(EDGE_CROWNS)
		var base := bottom + (8.0 if bush else 18.0) + randi_range(-3, 3)
		front.append(_edge_sprite(piece, Vector2(x_pos, base), randf() < 0.5))
		x_pos += randi_range(15, 20)

	# Weiter unten stehende Stücke werden später gezeichnet und verdecken die oberen
	for list: Array[Sprite2D] in [back, front]:
		list.sort_custom(func(a: Sprite2D, b: Sprite2D) -> bool: return a.position.y < b.position.y)
	for sprite in back:
		forest_edge.add_child(sprite)
	for sprite in front:
		forest_edge_front.add_child(sprite)


func _pick(pieces: Vector2i) -> int:
	return randi_range(pieces.x, pieces.y)


## Ein Waldrand-Stück, dessen Fußpunkt (unten in der Mitte) auf base steht.
func _edge_sprite(piece: int, base: Vector2, flip: bool) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = FOREST_EDGE_TEXTURE
	sprite.hframes = int(FOREST_EDGE_TEXTURE.get_width() / float(EDGE_PIECE_SIZE))
	sprite.frame = piece
	sprite.offset = Vector2(0.0, -EDGE_PIECE_SIZE * 0.5)
	sprite.position = base
	sprite.flip_h = flip
	return sprite
