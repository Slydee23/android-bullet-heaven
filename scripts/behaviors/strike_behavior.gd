class_name StrikeBehavior
extends WeaponBehavior
## Angriffsart „Einschlag“: Pro Angriff `amount` Einschläge auf Ziele des TargetPickers (Dreizack: zufällige Gegner im Bild,
## Bombenbeutel: zufällige Gegner in Reichweite). Gibt es weniger Ziele als Einschläge, gehen die übrigen auf zufällige
## Punkte (im Bild bzw. in Reichweite). Ohne jeden Gegner bleibt die Waffe schussbereit.
## Der StrikeManager übernimmt Flug, Zünder mit Warnfläche und das Auslösen (Schaden im Radius `area`, Effekt).
## Einstellungen hier gelten für alle Waffen, die diese Behavior-Datei nutzen (jede Waffe hat ihre eigene Unterressource).

## Effekt beim Auslösen (Blitz-Einschlag, Explosion)
@export var effect: EffectData
## Flugzeit vom Helden zum Ziel in Sekunden (0 = schlägt direkt am Ziel ein, z. B. Blitz)
@export var flight_time := 0.0
## true: Ziele und Ersatzpunkte im ganzen sichtbaren Bild (Reichweite ohne Bedeutung). false: im Umkreis `range`.
@export var whole_view := true
## Hat die Waffe eine Zündzeit (Stat `fuse`) mit Warnfläche?
@export var uses_fuse := false
## Werte auf der Waffenkarte
@export var card_stat_ids: Array[StringName] = [&"damage", &"cooldown", &"amount"]
## Bezeichnung der Anzahl im Detailfenster (z. B. „Blitze pro Angriff“, „Bomben pro Angriff“)
@export var amount_label_key := "STAT_AMOUNT"

## Arbeitsspeicher für die Zielplätze (gilt nur innerhalb eines fire()-Aufrufs)
var _targets := PackedInt32Array()


func fire(weapon: WeaponInstance, context: WeaponContext) -> bool:
	var amount := maxi(1, roundi(weapon.get_stat(&"amount")))
	var origin := context.player.global_position
	var max_range := weapon.get_stat(&"range")
	var found := weapon.target_picker.pick(origin, max_range, amount, context, _targets)
	if found == 0:
		return false
	var fuse := weapon.get_stat(&"fuse") if uses_fuse else 0.0
	var delay := flight_time + fuse
	for k in amount:
		var point: Vector2
		if k < found:
			# Mit Verzögerung (Bombe) dorthin zielen, wo der Gegner beim Auslösen voraussichtlich steht
			point = context.enemy_manager.predict_position(_targets[k], delay) if delay > 0.0 else context.enemy_manager.get_enemy_position(_targets[k])
		else:
			point = _random_point(origin, max_range, context)
		context.strikes.launch(weapon, origin, point, flight_time, fuse)
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
