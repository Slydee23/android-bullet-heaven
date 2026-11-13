class_name RandomInRangePicker
extends TargetPicker
## Zufällige Gegner im Umkreis max_range um den Helden, jeder nur einmal (Bombenbeutel: Wurfziele).


func pick(origin: Vector2, max_range: float, count: int, context: WeaponContext, out_indices: PackedInt32Array) -> int:
	var area := Rect2(origin - Vector2(max_range, max_range), Vector2(max_range, max_range) * 2.0)
	return context.enemy_manager.pick_random(area, origin, max_range, count, out_indices)
