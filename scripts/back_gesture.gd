extends Node
## Autoload "BackGesture": übersetzt die Android-Zurück-Geste in die Aktion "ui_cancel" (wie Esc am PC).
## Menüs reagieren dadurch nur auf "ui_cancel", und immer nur das oberste offene Menü bekommt sie.


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var event := InputEventAction.new()
		event.action = &"ui_cancel"
		event.pressed = true
		Input.parse_input_event(event)
