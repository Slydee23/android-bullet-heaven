class_name NearestDistinctPicker
extends TargetPicker
## Die nächsten Gegner, jeder nur einmal: nächster, zweitnächster, drittnächster …


func pick(origin: Vector2, max_range: float, count: int, context: WeaponContext, out_indices: PackedInt32Array) -> int:
	return context.enemy_manager.find_nearest_n(origin, max_range, count, out_indices)
