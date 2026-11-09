extends Node
## Zentrale Szenensteuerung (Autoload "SceneRouter"): Alle Wechsel zwischen großen Szenen laufen hier durch.
## Später kommen Hub und Innenräume dazu (siehe PLAN.md, „Hub-Stadt“).

const MAIN_MENU := "res://ui/main_menu.tscn"
const RUN := "res://scenes/run.tscn"


func go_to_main_menu() -> void:
	_change_to(MAIN_MENU)


## Startet einen neuen Run (auch „Nochmal“ nach Game Over).
func start_run() -> void:
	_change_to(RUN)


func _change_to(scene_path: String) -> void:
	# Eine neue Szene startet nie pausiert
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
