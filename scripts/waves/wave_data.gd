class_name WaveData
extends Resource
## Eine Welle: Dauer, wie viele Gegner gleichzeitig leben, wie schnell sie nachkommen, wie stark sie sind und welche Typen kommen.
## Alle Zahlen stehen in der Wellen-Datei (data/waves/*.tres), nicht im Code.

## Wie lange die Welle dauert (Sekunden)
@export var duration := 20.0
## Höchstzahl gleichzeitig lebender Gegner aus den normalen Spawns (Ereignisse und Boss zählen extra)
@export var max_alive := 15
## Neue Gegner pro Sekunde, solange weniger als max_alive leben
@export var spawn_rate := 1.5
## Faktoren dieser Welle: Lebenspunkte, Schaden an den Helden und Erfahrung je Gegner (1 = Grundwert)
@export var hp_factor := 1.0
@export var damage_factor := 1.0
@export var xp_factor := 1.0
@export var spawns: Array[WaveSpawn] = []
@export var events: Array[WaveEvent] = []
## Boss dieser Welle: erscheint zu Beginn, die Welle endet mit seinem Tod oder nach Ablauf der Zeit (Sieg)
@export var boss: EnemyData
