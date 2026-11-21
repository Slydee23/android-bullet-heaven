class_name StrikeBehavior
extends WeaponBehavior
## Angriffsart „Einschlag“: Pro Angriff `amount` Einschläge auf Ziele des TargetPickers (Dreizack: zufällige Gegner im Bild,
## Bombenbeutel: zufällige Gegner in Reichweite). Gibt es weniger Ziele als Einschläge, gehen die übrigen auf zufällige
## Punkte (im Bild bzw. in Reichweite). Ohne jeden Gegner bleibt die Waffe schussbereit.
## Der StrikeManager übernimmt Flug, Zünder mit Warnfläche und das Auslösen (Schaden im Radius `area`, Effekt).
## Einstellungen hier gelten für alle Waffen, die diese Behavior-Datei nutzen (jede Waffe hat ihre eigene Unterressource).

## Effekt beim Auslösen (Blitz-Einschlag, Explosion)
@export var effect: EffectData
## Optional ein zweiter Effekt, der gleichzeitig startet und mit der Wirkfläche wächst (z. B. Lichtblitz und Schockwelle am Boden,
## während der Blitz selbst gleich groß bleibt)
@export var impact_effect: EffectData
## Wirkradius `area`, für den impact_effect gezeichnet ist. Wächst `area` durch Upgrades, wird impact_effect im selben Verhältnis
## vergrößert und zeigt so die echte Reichweite. 0 = immer Originalgröße.
@export var effect_area_reference := 0.0
## So viele Sekunden vor dem Schaden startet der Effekt (z. B. der Blitz zuckt erst herab und schlägt dann ein:
## Schaden genau im Einschlag-Bild). 0 = Effekt beim Schaden.
@export var effect_lead := 0.0
## Flugzeit vom Helden zum Ziel in Sekunden (0 = schlägt direkt am Ziel ein, z. B. Blitz)
@export var flight_time := 0.0
## true: Ziele und Ersatzpunkte im ganzen sichtbaren Bild (Reichweite ohne Bedeutung). false: im Umkreis `range`.
@export var whole_view := true
## Hat die Waffe eine Zündzeit (Stat `fuse`) mit Warnfläche?
@export var uses_fuse := false
## Werte auf der Waffenkarte
@export var card_stat_ids: Array[StringName] = [&"damage", &"cooldown", &"amount"]
## Mindestabstand der Einschläge eines Angriffs als Vielfaches des Wirkradius `area` (0 = egal). Bomben: 1.5, damit sie sich
## kaum überlappen. Dafür werden mehr Ziel-Gegner gesucht als nötig und zu nahe liegende übersprungen.
@export var min_spacing := 0.0
## Bezeichnung der Anzahl im Detailfenster (z. B. „Blitze pro Angriff“, „Bomben pro Angriff“)
@export var amount_label_key := "STAT_AMOUNT"

## Mit Mindestabstand: so viele Ziel-Gegner je Einschlag werden gesucht, damit genug weit auseinander liegen
const SPACING_CANDIDATES := 3
## Versuche, einen Ersatzpunkt mit Mindestabstand zu finden
const SPACING_TRIES := 6

## Arbeitsspeicher für die Zielplätze und Einschlagpunkte (gilt nur innerhalb eines fire()-Aufrufs)
var _targets := PackedInt32Array()
var _points := PackedVector2Array()


func fire(weapon: WeaponInstance, context: WeaponContext) -> bool:
	var amount := maxi(1, roundi(weapon.get_stat(&"amount")))
	var origin := context.player.global_position
	var max_range := weapon.get_stat(&"range")
	var spacing := min_spacing * weapon.get_stat(&"area")
	var spacing_sq := spacing * spacing
	var wanted := amount * SPACING_CANDIDATES if spacing > 0.0 else amount
	var found := weapon.target_picker.pick(origin, max_range, wanted, context, _targets)
	if found == 0:
		return false
	var fuse := weapon.get_stat(&"fuse") if uses_fuse else 0.0
	var delay := flight_time + fuse
	_points.clear()
	# Zuerst Gegner als Ziele (zu nahe an einem schon gewählten Punkt: überspringen)
	for k in found:
		if _points.size() >= amount:
			break
		# Mit Verzögerung (Bombe) dorthin zielen, wo der Gegner beim Auslösen voraussichtlich steht
		var point := context.enemy_manager.predict_position(_targets[k], delay) if delay > 0.0 else context.enemy_manager.get_enemy_position(_targets[k])
		if _far_enough(point, spacing_sq):
			_points.append(point)
	# Übrige Einschläge auf zufällige Punkte, möglichst mit Abstand
	while _points.size() < amount:
		var point := _random_point(origin, max_range, context)
		for attempt in SPACING_TRIES:
			if _far_enough(point, spacing_sq):
				break
			point = _random_point(origin, max_range, context)
		_points.append(point)
	for point in _points:
		context.strikes.launch(weapon, origin, point, flight_time, fuse)
	return true


## Liegt point weit genug von allen schon gewählten Einschlägen dieses Angriffs?
func _far_enough(point: Vector2, spacing_sq: float) -> bool:
	if spacing_sq <= 0.0:
		return true
	for other in _points:
		if point.distance_squared_to(other) < spacing_sq:
			return false
	return true


## Ersatzpunkt für überzählige Einschläge: irgendwo im Bild bzw. irgendwo im Umkreis
func _random_point(origin: Vector2, max_range: float, context: WeaponContext) -> Vector2:
	if whole_view:
		var view := context.view_rect()
		return view.position + Vector2(randf() * view.size.x, randf() * view.size.y)
	return origin + Vector2.from_angle(randf() * TAU) * sqrt(randf()) * max_range


func on_removed(weapon: WeaponInstance, context: WeaponContext) -> void:
	context.strikes.remove_weapon(weapon)


func card_stats() -> Array[StringName]:
	return card_stat_ids


func stat_label_key(stat: StringName, default_key: String) -> String:
	if stat == &"range" and not whole_view:
		return "STAT_THROW_RANGE"
	if stat == &"amount":
		return amount_label_key
	return default_key


func supports_stat(stat: StringName) -> bool:
	match stat:
		&"amount", &"area":
			return true
		&"fuse":
			return uses_fuse
		&"range":
			# Zielt die Waffe auf das ganze Bild, hat die Reichweite keine Wirkung
			return not whole_view
	return super(stat)
