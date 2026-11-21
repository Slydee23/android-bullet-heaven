class_name AuraDrawer
extends Node2D
## Zeichnet alle Auren (z. B. die Feueraura der Flammenfackel) in einem einzigen _draw.
## Liegt in der Run-Szene vor dem EnemyManager, also am Boden unter Gegnern und Held.
## Eine Aura besteht aus:
## - einem Glutkreis am Boden genau im Schadensradius: flackernde Hitzefläche, glühender, unruhiger Rand und aufsteigende
##   Glutfunken. Er wird hier pixelgenau gezeichnet (keine vergrößerte Grafik), so bleibt er bei jedem Radius scharf.
## - einem Flammenmantel direkt am Helden (Streifen aus der Angriffsart, AuraBehavior.mantle_*): die Flammen hinter dem
##   Helden zeichnet dieser Node, die Funken davor der Kind-Node _front (z_index 1, über Held und Gegnern).

## Der Kreis liegt um die Körpermitte des Helden (wie die kreisenden Klingen), nicht um seine Füße.
## Treffer rechnen weiter von Fuß zu Fuß: Held und Gegner sind gleich hoch versetzt, die Abstände bleiben also gleich.
const BODY_HEIGHT := Player.BODY_CENTER_HEIGHT
## Hitzefläche: Grundfarbe und wie stark sie pulsiert
const HEAT_COLOR := Color(1.0, 0.32, 0.08, 0.13)
const HEAT_PULSE := 0.03
const BAND_COLOR := Color(1.0, 0.42, 0.12, 0.18)
## Breite des warmen Bands innen am Rand (Welt-Pixel)
const BAND_WIDTH := 8.0
## Glutrand: ein Pixelblock alle RIM_STEP Welt-Pixel, Farbe zwischen dunkler und heller Glut
const RIM_STEP := 3.0
const RIM_DARK := Color("#c45836")
const RIM_BRIGHT := Color("#f9c769")
## Glutfunken: Anzahl je Welt-Pixel Radius, Lebensdauer (Sekunden) und Steighöhe
const EMBERS_PER_RADIUS := 0.6
const EMBER_LIFE := 1.4
const EMBER_RISE := 16.0
const EMBER_HOT := Color("#ffe9a0")
const EMBER_COOL := Color("#c45836")

var _weapons: Array[WeaponInstance] = []
var _centers: Array[Node2D] = []
var _time := 0.0
var _front := Node2D.new()


func _ready() -> void:
	_front.z_index = 1
	_front.draw.connect(_draw_front)
	add_child(_front)


## Aura einer Waffe anmelden: Sie folgt center (dem Helden).
func add(weapon: WeaponInstance, center: Node2D) -> void:
	if weapon in _weapons:
		return
	_weapons.append(weapon)
	_centers.append(center)


## Aura einer Waffe abmelden (die Waffe wird abgelegt)
func remove(weapon: WeaponInstance) -> void:
	var index := _weapons.find(weapon)
	if index == -1:
		return
	_weapons.remove_at(index)
	_centers.remove_at(index)
	queue_redraw()
	_front.queue_redraw()


func _process(delta: float) -> void:
	if _weapons.is_empty():
		return
	_time += delta
	queue_redraw()
	_front.queue_redraw()


func _draw() -> void:
	for w in _weapons.size():
		var weapon := _weapons[w]
		var feet := _centers[w].global_position - global_position
		var center := feet - Vector2(0.0, BODY_HEIGHT)
		var radius := weapon.get_stat(&"range")
		_draw_ground(center, radius)
		var behavior := weapon.data.behavior as AuraBehavior
		if behavior and behavior.mantle_behind:
			_draw_strip(behavior.mantle_behind, behavior.mantle_behind_frame, feet + behavior.mantle_behind_offset, behavior.mantle_fps, self)


## Funken vor dem Helden (Kind-Node mit z_index 1)
func _draw_front() -> void:
	for w in _weapons.size():
		var behavior := _weapons[w].data.behavior as AuraBehavior
		if behavior and behavior.mantle_front:
			var feet := _centers[w].global_position - global_position
			_draw_strip(behavior.mantle_front, behavior.mantle_front_frame, feet + behavior.mantle_front_offset, behavior.mantle_fps, _front)


func _draw_strip(texture: Texture2D, frame: Vector2i, top_left: Vector2, fps: float, canvas: CanvasItem) -> void:
	@warning_ignore("integer_division")  # gewollt: Zahl ganzer Frames im Streifen
	var frames := maxi(1, texture.get_width() / frame.x)
	var index := int(_time * fps) % frames
	var size := Vector2(frame)
	canvas.draw_texture_rect_region(texture, Rect2(top_left.round(), size), Rect2(Vector2(index * frame.x, 0), size))


## Glutkreis am Boden im Schadensradius. Alles ohne gespeicherten Zustand: Flackern und Funken ergeben sich aus Zeit und Index.
func _draw_ground(center: Vector2, radius: float) -> void:
	# Hitzefläche, leicht pulsierend, mit wärmerem Band innen am Rand
	var heat := HEAT_COLOR
	heat.a += HEAT_PULSE * sin(_time * 3.0)
	draw_circle(center, radius, heat)
	draw_arc(center, radius - BAND_WIDTH * 0.5, 0.0, TAU, 96, BAND_COLOR, BAND_WIDTH)
	# Unruhiger Glutsaum: dunkle Glut außen, helle innen. Jeder Block flackert anders, die hellsten züngeln
	# als kleine Flamme nach oben (die Höhe wechselt mit dem Flackern)
	var blocks := maxi(24, int(TAU * radius / RIM_STEP))
	for k in blocks:
		var angle := TAU * k / blocks
		var flicker := 0.5 + 0.25 * sin(k * 1.7 + _time * 6.0) + 0.25 * sin(k * 0.37 - _time * 2.3)
		var direction := Vector2.from_angle(angle)
		var outer := (center + direction * (radius + 1.0)).round()
		var dark := RIM_DARK
		dark.a = 0.55 + 0.3 * flicker
		draw_rect(Rect2(outer - Vector2(1.0, 1.0), Vector2(3.0, 3.0)), dark)
		var bright := RIM_DARK.lerp(RIM_BRIGHT, flicker)
		bright.a = 0.5 + 0.5 * flicker
		var inner := (center + direction * (radius - 1.0)).round()
		var height := 2.0 + floorf(flicker * 4.0) if flicker > 0.6 else 2.0
		draw_rect(Rect2(inner - Vector2(1.0, height - 1.0), Vector2(2.0, height)), bright)
	# Glutfunken steigen aus der ganzen Fläche auf und verglühen
	var embers := int(radius * EMBERS_PER_RADIUS)
	for e in embers:
		var seed_value := e * 7919 + 17
		var phase := fposmod(_time / EMBER_LIFE + (seed_value % 97) / 97.0, 1.0)
		var angle := (seed_value % 360) * TAU / 360.0
		@warning_ignore("integer_division")  # gewollt: Pseudo-Zufall aus ganzen Zahlen
		var distance := radius * sqrt(((seed_value / 7) % 100) / 100.0)
		var point := center + Vector2.from_angle(angle) * distance + Vector2(0.0, -phase * EMBER_RISE)
		var color := EMBER_HOT.lerp(EMBER_COOL, phase)
		color.a = 1.0 - phase * phase
		# Frische Funken sind 2 Pixel groß, verglühende nur noch einer
		var size := 2.0 if phase < 0.5 else 1.0
		draw_rect(Rect2(point.round(), Vector2(size, size)), color)
