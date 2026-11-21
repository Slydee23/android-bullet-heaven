class_name TargetPicker
extends Resource
## Basis für die Zielwahl einer Waffe (Grundsatzentscheidung 7): Wen oder was greift sie an?
## Neue Zielwahl = neues Skript, das von dieser Klasse erbt. Der aktive Picker liegt in der WeaponInstance,
## damit ein Upgrade ihn austauschen kann (z. B. Bomben wechseln auf „Gegnergruppen“).


## Wählt bis zu count verschiedene Ziele um origin (Füße) im Umkreis max_range.
## Schreibt die Plätze der Gegner nach out_indices und liefert die Anzahl. Die Plätze gelten nur im aktuellen Frame:
## Wer ein Ziel länger merken muss, nimmt EnemyManager.get_id().
func pick(_origin: Vector2, _max_range: float, _count: int, _context: WeaponContext, _out_indices: PackedInt32Array) -> int:
	return 0
