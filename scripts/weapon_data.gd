class_name WeaponData
extends Resource
## Datendatei einer Waffe (data/weapons/*.tres). Neue Waffe = neue Datei, kein neuer Code.
## Eine Waffe ist ein echter Fantasy-Gegenstand (Zauberstab, Schwert, Dreizack …), ihre Fähigkeit steckt in `behavior`.
## Werte stehen in `base_stats` als Liste „Stat-ID → Wert“: Ein neuer Stat ist nur eine neue Zeile dort.
## Gelesen werden sie immer über WeaponInstance.get_stat() (ab M6 rechnet dort das Werte-System).
##
## Bekannte Stats (Geschoss-Waffen): damage, cooldown (Sekunden), range (Welt-Pixel), amount (Geschosse pro Angriff),
## projectile_speed, projectile_radius, projectile_lifetime (Sekunden), pierce (Anzahl Gegner, die ein Geschoss trifft).

@export var id := &""
## Übersetzungsschlüssel von Name und Beschreibung (Level-Up-Karte, Statusbildschirm)
@export var name_key := ""
@export var description_key := ""
@export var icon: Texture2D
## Schadens-Tags (z. B. projectile, magic), damit Boni nur bestimmte Waffen betreffen
@export var tags: Array[StringName] = []
## Element der Waffe (siehe Elements). Waffen ohne Element sind physisch.
@export var element: StringName = Elements.PHYSICAL
## Gehört die Waffe zu den von Anfang an freigeschalteten Waffen? (später kommt eine Freischalt-ID dazu)
@export var default_unlocked := true
@export var base_stats: Dictionary = {}
## Wie die Waffe angreift (z. B. ProjectileBehavior)
@export var behavior: WeaponBehavior
## Wen sie angreift (z. B. NearestDistinctPicker). Fehlt er, gilt NearestDistinctPicker.
@export var target_picker: TargetPicker
## Effekte, die bei Ereignissen eingreifen (z. B. Ricochet)
@export var effects: Array[WeaponEffect] = []
## Geschoss-Bild als Streifen, Blick nach Osten (Frame-Anzahl = Bildbreite ÷ frame_width)
@export var projectile_texture: Texture2D
@export var frame_width := 16
@export var animation_fps := 10.0
