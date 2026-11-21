class_name SweepBehavior
extends WeaponBehavior
## Angriffsart „Hieb“ (Dornenpeitsche): Ein Hieb schnellt gerade vom Helden weg und trifft alle Gegner in seinem Streifen
## (Länge `range`, halbe Breite `area`, beginnt `start_offset` Pixel neben dem Helden).
## Der erste Hieb geht in eine zufällige der 4 Himmelsrichtungen. Weitere Hiebe (`amount`) gehen zuerst auf die Gegenseite,
## dann in die beiden übrigen Himmelsrichtungen, zuletzt in die Diagonalen (höchstens 8). Alle Hiebe eines Angriffs gleichzeitig.
## Kein Ricochet: Die Peitsche wird nur über weitere Hiebe stärker.

## Reihenfolge der Hiebe als Drehung zur ersten Richtung: Gegenseite, die beiden Seiten, dann die vier Diagonalen
const ORDER: Array[float] = [0.0, PI, PI * 0.5, -PI * 0.5, PI * 0.25, PI * 0.75, -PI * 0.25, -PI * 0.75]
const MAX_LASHES := 8
## So lang ist der Hieb im Bild (whip_slash.png, Generator SLASH_LENGTH): Längere Hiebe (Upgrades) werden gestreckt
const IMAGE_LENGTH := 90.0
const SWEEP_STATS: Array[StringName] = [&"amount", &"area"]

## Effekt des Hiebs (Bild schaut nach Osten, Drehpunkt = Held)
@export var effect: EffectData
## Abstand vom Helden bis zum Anfang des Hiebs (Welt-Pixel)
@export var start_offset := 8.0


func fire(weapon: WeaponInstance, context: WeaponContext) -> bool:
	var origin := context.player.global_position
	var lashes := clampi(roundi(weapon.get_stat(&"amount")), 1, MAX_LASHES)
	var first := (randi() % 4) * PI * 0.5
	var length := weapon.get_stat(&"range")
	var half_width := weapon.get_stat(&"area")
	var amount := weapon.get_stat(&"damage")
	for k in lashes:
		var angle := first + ORDER[k]
		var dir := Vector2.from_angle(angle)
		weapon.total_damage += context.enemy_manager.damage_in_strip(origin, dir, start_offset, length, half_width, amount, weapon.data.element)
		if context.effects and effect:
			# Nach links waagerecht gespiegelt statt um 180° gedreht, damit sich die Spitze auch dort nach oben einrollt
			var stretch := length / IMAGE_LENGTH
			var body := origin - Vector2(0.0, Player.BODY_CENTER_HEIGHT)
			if dir.x < -0.01:
				context.effects.play(effect, body, angle - PI, Vector2(-stretch, 1.0))
			else:
				context.effects.play(effect, body, angle, Vector2(stretch, 1.0))
	# Der Hieb schlägt immer, auch ohne Gegner (wie in Vampire Survivors)
	return true


func card_stats() -> Array[StringName]:
	return [&"damage", &"cooldown", &"amount"]


func stat_label_key(stat: StringName, default_key: String) -> String:
	match stat:
		&"amount":
			return "STAT_LASHES"
		&"range":
			return "STAT_LENGTH"
		&"area":
			return "STAT_WIDTH"
	return default_key


func supports_stat(stat: StringName) -> bool:
	return stat in SWEEP_STATS or super(stat)
