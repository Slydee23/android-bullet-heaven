class_name EnemyData
extends Resource
## Werte eines Gegnertyps. Neuer Gegner = neue .tres-Datei in data/enemies/, kein neuer Code.

@export var id := &""
## Name (Übersetzungsschlüssel), z. B. für die Boss-Leiste und das Debug-Menü
@export var name_key := ""
## Lauf-Animation als horizontaler Streifen (Frame-Anzahl = Bildbreite ÷ frame_width)
@export var walk_texture: Texture2D
## Optional: Angriffsstreifen (gleiche Frame-Breite), z. B. Sprung des Ghuls, Zauber des Kultisten. Die Fähigkeit wählt die Frames.
@export var attack_texture: Texture2D
## Optional: Sonder-Pose (gleiche Frame-Breite), z. B. das Aufblähen des Pestbringers vor dem Platzen
@export var special_texture: Texture2D
## Optional: Tod-Animation als Effekt (statt Tod-Staub). Ihr Drehpunkt liegt auf den Füßen, sie wird wie der Gegner gespiegelt.
@export var death_effect: EffectData
## So viele Pixel stehen die Füße über dem unteren Bildrand (z. B. Platz für Einschlag-Spuren unter dem Boss)
@export var foot_offset := 0.0
## Färbung des ganzen Gegners (z. B. stärkere Elite-Varianten), Weiß = unverändert
@export var tint := Color.WHITE
## Optional: besonderes Verhalten (Sprung, Fernzauber, Platzen, Boss), siehe EnemyAbility
@export var ability: EnemyAbility
@export var frame_width := 32
@export var animation_fps := 6.0
## Größe eines Bildpixels in Welt-Pixeln (1 = normal, z. B. 2 für einen doppelt so großen Boss)
@export var draw_scale := 1.0
## Laufgeschwindigkeit in Welt-Pixeln pro Sekunde (Held: 120)
@export var speed := 40.0
@export var max_hp := 10.0
@export var contact_damage := 5.0
## Sekunden zwischen zwei Treffern dieses Gegners. Viele Gegner zusammen begrenzen die I-Frames des Helden.
@export var attack_interval := 1.0
## Zusätzlicher Abstand zum Helden, aus dem angegriffen wird (0 = Nahkampf, also bei Berührung)
@export var attack_range := 0.0
## Körperradius in Welt-Pixeln um die Füße: Abstand zu anderen Gegnern und zum Helden, Trefferfläche
@export var radius := 10.0
## Stirbt nie (Übungspuppe): Lebenspunkte fallen höchstens auf 1 und füllen sich kurz nach dem letzten Treffer wieder auf
@export var immortal := false
## Bewegt sich nie und lässt sich nicht von anderen Gegnern wegschieben (Übungspuppe)
@export var anchored := false
## Erfahrung, die der Gegner beim Tod als Seelensplitter fallen lässt (0 = keinen)
@export var xp_value := 1
