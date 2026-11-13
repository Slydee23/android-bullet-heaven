class_name DebugMenu
extends Control
## Debug-Menü: kleines Fenster im Run, nur in Test-Builds (aus Godot gestartet) erreichbar.
## Testwerte zum Ausprobieren, wächst mit dem Spiel. Das Spiel kann dabei weiterlaufen (siehe Settings.debug_keep_running).
## Aufgeteilt in Reiter: Allgemein (Kamera, Spiel, I-Frames, Treffer am Helden), Waffen, Gegner, Status.

signal closed

const PixelUI := preload("res://scripts/pixel_ui.gd")
## Testknöpfe: Anteil der maximalen HP
const TEST_SMALL_HIT_SHARE := 0.05
const TEST_HIT_SHARE := 0.2
const TEST_SELF_DAMAGE_SHARE := 0.1
## Test-Boni als Ersatz für die späteren Upgrades (M6)
const SWORD := preload("res://data/weapons/orbit_sword.tres")
const TORCH := preload("res://data/weapons/flame_torch.tres")
const TRIDENT := preload("res://data/weapons/trident.tres")
const BOMBS := preload("res://data/weapons/bomb_bag.tres")
const WHIP := preload("res://data/weapons/thorn_whip.tres")
## Reihenfolge für „Startwaffe wechseln“
const START_WEAPONS: Array[WeaponData] = [
	preload("res://data/weapons/arcane_wand.tres"), SWORD, TORCH, TRIDENT, BOMBS, WHIP,
]
## Durchschlag „unendlich“ für den Wellen-Test (so viele Gegner trifft ein Geschoss)
const PIERCE_ENDLESS := 999.0
const BONUS_DURATION := 1.0
const BONUS_RADIUS := 16.0
const BONUS_TICK := -0.1
## Gegner-Hilfen: Lebenspunkte-Faktoren, so viele Gegner pro Klick im Ring um den Helden, Übungspuppe
const HP_FACTORS: Array[float] = [1.0, 5.0, 20.0]
const SKELETON := preload("res://data/enemies/skeleton.tres")
const DUMMY := preload("res://data/enemies/training_dummy.tres")
const BURST_COUNT := 100
const BURST_MIN_DISTANCE := 220.0
const BURST_MAX_DISTANCE := 360.0
const DUMMY_OFFSET := Vector2(70.0, 0.0)
## Status geben: wirkt auf alle Gegner in diesem Umkreis um den Helden
const STATUS_RADIUS := 160.0
const BURNING := preload("res://data/status/burning.tres")
const POISONED := preload("res://data/status/poisoned.tres")
const SHOCKED := preload("res://data/status/shocked.tres")
const CHILLED := preload("res://data/status/chilled.tres")

## Zuletzt geöffneter Reiter (bleibt erhalten, solange das Spiel läuft)
static var _last_page := 0

## Held, auf den sich die Testwerte beziehen (setzt die Run-Szene vor dem Öffnen)
var player: Player
## Waffen des Helden, auf die sich „+1 Projektil“ bezieht (setzt die Run-Szene vor dem Öffnen)
var weapon_holder: WeaponHolder
## Gegner für „Test-Crit“ (setzt die Run-Szene vor dem Öffnen)
var enemy_manager: EnemyManager

var _closing := false
var _shown_iframes := -1.0

@onready var tab_buttons: Array[Button] = [%TabGeneral, %TabWeapons, %TabEnemies, %TabStatus]
@onready var pages: Array[Control] = [%GeneralPage, %WeaponsPage, %EnemiesPage, %StatusPage]
@onready var hp_buttons: Array[Button] = [%Hp1Button, %Hp5Button, %Hp20Button]
@onready var add_100_button: Button = %Add100Button
@onready var remove_enemies_button: Button = %RemoveEnemiesButton
@onready var dummy_button: Button = %DummyButton
@onready var burn_button: Button = %BurnButton
@onready var poison_button: Button = %PoisonButton
@onready var shock_button: Button = %ShockButton
@onready var chill_button: Button = %ChillButton
@onready var zoom_near_button: Button = %ZoomNearButton
@onready var zoom_far_button: Button = %ZoomFarButton
@onready var zoom_dynamic_button: Button = %ZoomDynamicButton
@onready var game_paused_button: Button = %GamePausedButton
@onready var game_running_button: Button = %GameRunningButton
@onready var iframe_min_slider: HSlider = %IFrameMinSlider
@onready var iframe_min_value: Label = %IFrameMinValue
@onready var iframe_max_slider: HSlider = %IFrameMaxSlider
@onready var iframe_max_value: Label = %IFrameMaxValue
@onready var iframe_share_slider: HSlider = %IFrameShareSlider
@onready var iframe_share_value: Label = %IFrameShareValue
@onready var iframe_last_label: Label = %IFrameLastLabel
@onready var test_small_hit_button: Button = %TestSmallHitButton
@onready var test_hit_button: Button = %TestHitButton
@onready var test_self_damage_button: Button = %TestSelfDamageButton
@onready var extra_projectile_button: Button = %ExtraProjectileButton
@onready var extra_projectile_reset_button: Button = %ExtraProjectileResetButton
@onready var test_crit_button: Button = %TestCritButton
@onready var add_sword_button: Button = %AddSwordButton
@onready var add_torch_button: Button = %AddTorchButton
@onready var add_trident_button: Button = %AddTridentButton
@onready var add_bombs_button: Button = %AddBombsButton
@onready var clear_weapons_button: Button = %ClearWeaponsButton
@onready var add_whip_button: Button = %AddWhipButton
@onready var start_weapon_button: Button = %StartWeaponButton
@onready var vulnerable_button: Button = %VulnerableButton
@onready var invincible_button: Button = %InvincibleButton
@onready var ricochet_button: Button = %RicochetButton
@onready var pierce_button: Button = %PierceButton
@onready var bonus_duration_button: Button = %BonusDurationButton
@onready var bonus_radius_button: Button = %BonusRadiusButton
@onready var bonus_tick_button: Button = %BonusTickButton
@onready var iframe_reset_button: Button = %IFrameResetButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	theme = PixelUI.make_theme()

	zoom_near_button.button_pressed = Settings.camera_zoom_mode == Settings.CameraZoomMode.NEAR
	zoom_far_button.button_pressed = Settings.camera_zoom_mode == Settings.CameraZoomMode.FAR
	zoom_dynamic_button.button_pressed = Settings.camera_zoom_mode == Settings.CameraZoomMode.DYNAMIC

	zoom_near_button.pressed.connect(Settings.set_camera_zoom_mode.bind(Settings.CameraZoomMode.NEAR))
	zoom_far_button.pressed.connect(Settings.set_camera_zoom_mode.bind(Settings.CameraZoomMode.FAR))
	zoom_dynamic_button.pressed.connect(Settings.set_camera_zoom_mode.bind(Settings.CameraZoomMode.DYNAMIC))

	game_paused_button.button_pressed = not Settings.debug_keep_running
	game_running_button.button_pressed = Settings.debug_keep_running
	game_paused_button.pressed.connect(Settings.set_debug_keep_running.bind(false))
	game_running_button.pressed.connect(Settings.set_debug_keep_running.bind(true))

	_setup_iframe_slider(iframe_min_slider, Settings.MIN_IFRAME_DURATION, Settings.MAX_IFRAME_DURATION)
	_setup_iframe_slider(iframe_max_slider, Settings.MIN_IFRAME_DURATION, Settings.MAX_IFRAME_DURATION)
	_setup_iframe_slider(iframe_share_slider, Settings.MIN_IFRAME_SHARE, Settings.MAX_IFRAME_SHARE)
	_show_iframe_rule()
	iframe_min_slider.value_changed.connect(_on_iframe_min_changed)
	iframe_max_slider.value_changed.connect(_on_iframe_max_changed)
	iframe_share_slider.value_changed.connect(_on_iframe_slider_changed)

	test_small_hit_button.pressed.connect(_on_test_hit_pressed.bind(TEST_SMALL_HIT_SHARE))
	test_hit_button.pressed.connect(_on_test_hit_pressed.bind(TEST_HIT_SHARE))
	test_self_damage_button.pressed.connect(_on_test_self_damage_pressed)
	extra_projectile_button.pressed.connect(_on_extra_projectile_pressed)
	extra_projectile_reset_button.pressed.connect(_on_extra_projectile_reset_pressed)
	test_crit_button.pressed.connect(_on_test_crit_pressed)
	add_sword_button.pressed.connect(_on_add_weapon_pressed.bind(SWORD))
	add_torch_button.pressed.connect(_on_add_weapon_pressed.bind(TORCH))
	add_trident_button.pressed.connect(_on_add_weapon_pressed.bind(TRIDENT))
	add_bombs_button.pressed.connect(_on_add_weapon_pressed.bind(BOMBS))
	clear_weapons_button.pressed.connect(_on_clear_weapons_pressed)
	add_whip_button.pressed.connect(_on_add_weapon_pressed.bind(WHIP))
	start_weapon_button.pressed.connect(_on_start_weapon_pressed)
	_show_start_weapon()
	if player:
		vulnerable_button.button_pressed = not player.debug_invincible
		invincible_button.button_pressed = player.debug_invincible
	vulnerable_button.pressed.connect(_set_invincible.bind(false))
	invincible_button.pressed.connect(_set_invincible.bind(true))
	ricochet_button.pressed.connect(_add_bonus.bind(&"ricochet", 1.0, &"arcane_wand"))
	pierce_button.pressed.connect(_add_bonus.bind(&"pierce", PIERCE_ENDLESS, &"arcane_wand"))
	bonus_duration_button.pressed.connect(_add_bonus.bind(&"duration", BONUS_DURATION, &""))
	bonus_radius_button.pressed.connect(_add_bonus.bind(&"range", BONUS_RADIUS, &"flame_torch"))
	bonus_tick_button.pressed.connect(_add_bonus.bind(&"cooldown", BONUS_TICK, &"flame_torch"))
	iframe_reset_button.pressed.connect(_on_iframe_reset_pressed)
	back_button.pressed.connect(close)

	for k in tab_buttons.size():
		tab_buttons[k].pressed.connect(_show_page.bind(k))
	_show_page(_last_page)
	tab_buttons[_last_page].button_pressed = true

	for k in hp_buttons.size():
		hp_buttons[k].pressed.connect(_on_hp_factor_pressed.bind(HP_FACTORS[k]))
		if enemy_manager and is_equal_approx(enemy_manager.hp_multiplier, HP_FACTORS[k]):
			hp_buttons[k].button_pressed = true
	add_100_button.pressed.connect(_on_add_100_pressed)
	remove_enemies_button.pressed.connect(_on_remove_enemies_pressed)
	dummy_button.pressed.connect(_on_dummy_pressed)
	burn_button.pressed.connect(_give_status.bind(BURNING))
	poison_button.pressed.connect(_give_status.bind(POISONED))
	shock_button.pressed.connect(_give_status.bind(SHOCKED))
	chill_button.pressed.connect(_give_status.bind(CHILLED))


func _set_invincible(on: bool) -> void:
	if player:
		player.debug_invincible = on


## Startwaffe reihum gegen die nächste der sechs Waffen tauschen
func _on_start_weapon_pressed() -> void:
	if not weapon_holder or weapon_holder.start_weapons.is_empty():
		return
	var current := weapon_holder.start_weapons[0].data
	var index := 0
	for k in START_WEAPONS.size():
		if START_WEAPONS[k].id == current.id:
			index = k
	weapon_holder.replace_start_weapon(START_WEAPONS[(index + 1) % START_WEAPONS.size()])
	_show_start_weapon()


func _show_start_weapon() -> void:
	if weapon_holder and not weapon_holder.start_weapons.is_empty():
		start_weapon_button.text = tr("DEBUG_START_WEAPON") % tr(weapon_holder.start_weapons[0].data.name_key)


## Zeigt nur die Seite des gewählten Reiters
func _show_page(index: int) -> void:
	_last_page = index
	for k in pages.size():
		pages[k].visible = k == index


func _on_hp_factor_pressed(factor: float) -> void:
	if enemy_manager:
		enemy_manager.set_hp_multiplier(factor)


## 100 Skelette sofort im Ring um den Helden (zum Prüfen von Flächenwaffen und FPS)
func _on_add_100_pressed() -> void:
	if enemy_manager and player:
		enemy_manager.spawn_ring(SKELETON, player.global_position, BURST_COUNT, BURST_MIN_DISTANCE, BURST_MAX_DISTANCE)


func _on_remove_enemies_pressed() -> void:
	if enemy_manager:
		enemy_manager.remove_all()


## Übungspuppe neben dem Helden: stirbt nie, bewegt sich nicht, greift nicht an
func _on_dummy_pressed() -> void:
	if enemy_manager and player:
		enemy_manager.spawn(DUMMY, player.global_position + DUMMY_OFFSET)


## Status auf alle Gegner (und Puppen) im Umkreis um den Helden
func _give_status(status: StatusEffectData) -> void:
	if enemy_manager and player:
		enemy_manager.apply_status_in_radius(player.global_position, STATUS_RADIUS, status)


func _process(_delta: float) -> void:
	if player and player.last_iframe_duration != _shown_iframes:
		_shown_iframes = player.last_iframe_duration
		iframe_last_label.text = tr("DEBUG_IFRAME_LAST") % _shown_iframes


func _setup_iframe_slider(slider: HSlider, minimum: float, maximum: float) -> void:
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = 0.01
	# Beim Ziehen nicht ständig speichern, erst beim Loslassen
	slider.drag_ended.connect(func(_changed: bool) -> void: Settings.save_settings())


## Zeigt die geltende Regel des Helden an, ohne dabei die Regler-Signale auszulösen.
func _show_iframe_rule() -> void:
	iframe_min_slider.set_value_no_signal(player.iframe_rule.min_duration)
	iframe_max_slider.set_value_no_signal(player.iframe_rule.max_duration)
	iframe_share_slider.set_value_no_signal(player.iframe_rule.reference_share)
	iframe_min_value.text = "%.2f s" % iframe_min_slider.value
	iframe_max_value.text = "%.2f s" % iframe_max_slider.value
	iframe_share_value.text = "%d %%" % roundi(iframe_share_slider.value * 100.0)


## Die Mindestdauer schiebt die Höchstdauer mit, damit sie nie darüber liegt.
func _on_iframe_min_changed(value: float) -> void:
	if value > iframe_max_slider.value:
		iframe_max_slider.set_value_no_signal(value)
	_on_iframe_slider_changed(value)


## Die Höchstdauer schiebt die Mindestdauer mit, damit sie nie darunter liegt.
func _on_iframe_max_changed(value: float) -> void:
	if value < iframe_min_slider.value:
		iframe_min_slider.set_value_no_signal(value)
	_on_iframe_slider_changed(value)


func _on_iframe_slider_changed(_value: float) -> void:
	Settings.set_debug_iframes(iframe_min_slider.value, iframe_max_slider.value, iframe_share_slider.value, false)
	_show_iframe_rule()


func _on_test_hit_pressed(share: float) -> void:
	player.take_damage(player.max_hp * share)


func _on_test_self_damage_pressed() -> void:
	player.take_self_damage(player.max_hp * TEST_SELF_DAMAGE_SHARE)


## Testbonus „+1 Projektil“ auf alle Waffen, die mehrere Einheiten kennen (weitere Geschosse, weitere Klingen).
## Später rechnet das Werte-System solche Boni aus Upgrades und Artefakten.
func _on_extra_projectile_pressed() -> void:
	_add_bonus(&"amount", 1.0, &"")


## Nimmt alle Test-Boni aller Waffen zurück
func _on_extra_projectile_reset_pressed() -> void:
	if not weapon_holder:
		return
	for weapon in weapon_holder.all_weapons():
		weapon.reset_bonuses()


## Testbonus auf einen Stat: auf alle Waffen, die ihn verstehen, oder nur auf die Waffe mit der ID only_id.
## Grenzen der Waffe (stat_limits) greifen dabei wie bei echten Upgrades.
func _add_bonus(stat: StringName, value: float, only_id: StringName) -> void:
	if not weapon_holder:
		return
	for weapon in weapon_holder.all_weapons():
		if only_id != &"" and weapon.data.id != only_id:
			continue
		if weapon.data.behavior and weapon.data.behavior.supports_stat(stat):
			weapon.add_flat(stat, value)


## Alle Run-Waffen ablegen (nur 3 Run-Plätze: so lassen sich alle Waffen nacheinander testen). Der Zauberstab bleibt.
func _on_clear_weapons_pressed() -> void:
	if weapon_holder:
		weapon_holder.clear_run_weapons()


## Waffe auf einen freien Run-Platz legen (zum Testen neuer Waffen ohne Level-Up)
func _on_add_weapon_pressed(data: WeaponData) -> void:
	if weapon_holder:
		weapon_holder.add_run_weapon(data)


## Kritischer Treffer mit zufälligem Element auf den nächsten Gegner, zum Ansehen der Schadenszahlen (Größen, Farben, Tod)
func _on_test_crit_pressed() -> void:
	if not enemy_manager or not player:
		return
	var target := enemy_manager.find_nearest(player.global_position, 600.0)
	if target != -1:
		enemy_manager.damage(target, randf_range(40.0, 140.0), Elements.ALL.pick_random(), true)


func _on_iframe_reset_pressed() -> void:
	Settings.reset_debug_iframes()
	_show_iframe_rule()


func close() -> void:
	if _closing:
		return
	_closing = true
	Settings.save_settings()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# Esc am PC bzw. Zurück-Geste am Handy (siehe BackGesture)
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
