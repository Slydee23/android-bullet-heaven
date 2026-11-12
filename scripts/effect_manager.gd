class_name EffectManager
extends Node2D
## Spielt alle kurzen Bildeffekte (Treffer, Tod, später Blitze, Explosionen) zentral ab, wie der EnemyManager:
## Werte liegen in Arrays, ein Effekt wird nach dem Abspielen durch den letzten ersetzt, gezeichnet wird alles in einem Durchgang.
## Neuer Effekt = neue EffectData-Datei, kein neuer Code.

const MAX_EFFECTS := 512

var count := 0

var _positions := PackedVector2Array()
var _ages := PackedFloat32Array()
## Index in _effects (ein Effekt speichert nur diese Zahl statt der ganzen Datendatei)
var _slots := PackedInt32Array()
var _effects: Array[EffectData] = []
var _was_drawn := false


func _ready() -> void:
	_positions.resize(MAX_EFFECTS)
	_ages.resize(MAX_EFFECTS)
	_slots.resize(MAX_EFFECTS)


## Spielt den Effekt einmal an der Weltposition pos ab (Fußpunkt-Ebene, wie alle Positionen im Spiel).
## Ist der Pool voll, entfällt der Effekt einfach (er ist nur Optik).
func play(effect: EffectData, pos: Vector2) -> void:
	if count >= MAX_EFFECTS or not effect or not effect.texture:
		return
	var slot := _effects.find(effect)
	if slot == -1:
		_effects.append(effect)
		slot = _effects.size() - 1
	_positions[count] = pos
	_ages[count] = 0.0
	_slots[count] = slot
	count += 1


func _process(delta: float) -> void:
	# Rückwärts, weil das Entfernen den letzten Effekt auf den freien Platz setzt (der wurde schon weitergezählt)
	for i in range(count - 1, -1, -1):
		_ages[i] += delta
		var effect := _effects[_slots[i]]
		if _ages[i] * effect.fps >= _frame_count(effect):
			count -= 1
			_positions[i] = _positions[count]
			_ages[i] = _ages[count]
			_slots[i] = _slots[count]
	# Nur neu zeichnen, solange etwas läuft (und einmal danach, um das letzte Bild zu löschen)
	if count > 0 or _was_drawn:
		queue_redraw()


func _draw() -> void:
	_was_drawn = count > 0
	for i in count:
		var effect := _effects[_slots[i]]
		var frames := _frame_count(effect)
		var frame := mini(int(_ages[i] * effect.fps), frames - 1)
		var size := Vector2(effect.frame_width, effect.texture.get_height())
		var top_left := _positions[i] - size * 0.5
		if effect.anchor == EffectData.Anchor.FEET:
			# Der Punkt ist der Fuß: Das Bild steht unten bündig darauf (wie die Gegner)
			top_left = _positions[i] + Vector2(-size.x * 0.5, 1.0 - size.y)
		draw_texture_rect_region(effect.texture, Rect2(top_left, size), Rect2(Vector2(frame * effect.frame_width, 0), size))


func _frame_count(effect: EffectData) -> int:
	return maxi(1, int(effect.texture.get_width() / float(effect.frame_width)))
