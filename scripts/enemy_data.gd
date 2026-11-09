class_name EnemyData
extends Resource
## Werte eines Gegnertyps. Neuer Gegner = neue .tres-Datei in data/enemies/, kein neuer Code.

@export var id := &""
## Lauf-Animation als horizontaler Streifen (Frame-Anzahl = Bildbreite ÷ frame_width)
@export var walk_texture: Texture2D
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
