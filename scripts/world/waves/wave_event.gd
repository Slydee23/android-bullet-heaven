class_name WaveEvent
extends Resource
## Ereignis mitten in einer Welle: eine Formation, die sich in Abständen wiederholt. Vorher erscheint eine kurze Warnung.
## RING: Gegner umstellen den Helden gleichmäßig auf einem Kreis knapp außerhalb des Bildes (Einkesselung).
## RUSH: Ein Rudel stürmt in einer Reihe von einer zufälligen Seite heran.

enum Pattern { RING, RUSH }

@export var pattern := Pattern.RING
@export var enemy: EnemyData
@export var count := 12
## Sekunden nach Wellenbeginn bis zum ersten Mal, danach alle `interval` Sekunden (0 = nur einmal)
@export var first_delay := 15.0
@export var interval := 30.0
