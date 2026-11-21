class_name RandomVisiblePicker
extends TargetPicker
## Zufällige Gegner im sichtbaren Bild, jeder nur einmal (Dreizack: Blitze von oben). Die Reichweite spielt keine Rolle.


func pick(origin: Vector2, _max_range: float, count: int, context: WeaponContext, out_indices: PackedInt32Array) -> int:
	return context.enemy_manager.pick_random(context.view_rect(), origin, 0.0, count, out_indices)
