class_name WeaponData
extends Resource
## Datendatei einer Waffe (data/weapons/*.tres). Neue Waffe = neue Datei, kein neuer Code.
## Werte stehen in `base_stats` als Liste „Stat-ID → Wert“: Ein neuer Stat ist nur eine neue Zeile dort.
## Gelesen werden sie immer über WeaponInstance.get_stat() (ab M6 rechnet dort das Werte-System).
##
## Bekannte Stats (Geschoss-Waffen): damage, cooldown (Sekunden), range (Welt-Pixel), projectile_speed,
## projectile_radius, projectile_lifetime (Sekunden), pierce (Anzahl Gegner, die ein Geschoss trifft).

## Wie das Ziel gewählt wird (Grundsatzentscheidung 7). Vorerst ist nur NEAREST umgesetzt.
enum TargetMode { NEAREST, FACING }

@export var id := &""
## Übersetzungsschlüssel des Namens
@export var name_key := ""
@export var icon: Texture2D
## Schadens-Tags (z. B. projectile, magic), damit Boni nur bestimmte Waffen betreffen
@export var tags: Array[StringName] = []
@export var target_mode := TargetMode.NEAREST
@export var base_stats: Dictionary = {}
## Wie die Waffe angreift (z. B. ProjectileBehavior)
@export var behavior: WeaponBehavior
## Effekte, die bei Ereignissen eingreifen (z. B. Ricochet)
@export var effects: Array[WeaponEffect] = []
## Geschoss-Bild als Streifen, Blick nach Osten (Frame-Anzahl = Bildbreite ÷ frame_width)
@export var projectile_texture: Texture2D
@export var frame_width := 16
@export var animation_fps := 10.0
