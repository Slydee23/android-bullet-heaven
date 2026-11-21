class_name WeaponData
extends Resource
## Datendatei einer Waffe (data/weapons/*.tres). Neue Waffe = neue Datei, kein neuer Code.
## Eine Waffe ist ein echter Fantasy-Gegenstand (Zauberstab, Schwert, Dreizack …), ihre Fähigkeit steckt in `behavior`.
## Werte stehen in `base_stats` als Liste „Stat-ID → Wert“: Ein neuer Stat ist nur eine neue Zeile dort.
## Gelesen werden sie immer über WeaponInstance.get_stat() (ab M6 rechnet dort das Werte-System).
##
## Bekannte Stats (Geschoss-Waffen): damage, cooldown (Sekunden), range (Welt-Pixel), amount (Geschosse pro Angriff),
## projectile_speed, projectile_radius, projectile_lifetime (Sekunden), pierce (Anzahl Gegner, die ein Geschoss trifft),
## ricochet (so oft prallt ein Geschoss nach dem letzten Durchschlag zum nächsten Gegner ab; nur für Waffen, die schießen oder werfen).
## Peitsche: amount (Hiebe), range (Länge des Hiebs), area (halbe Breite des Treffer-Streifens).
## Kreisende Klingen: amount (Klingen), range (Kreisradius), orbit_speed (Bogenmaß pro Sekunde), duration (Sekunden sichtbar),
## cooldown (Zyklus in Sekunden), hit_interval (Sekunden, bis eine Klinge denselben Gegner wieder trifft), projectile_radius.
## Aura: range (Radius), cooldown (Sekunden zwischen zwei Schadens-Pulsen), damage (pro Puls).

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
## Wie viele Entwicklungsstufen die Waffe hat (nach Level 10, Anzeige „Entwicklung 1 von 3“)
@export var max_evolution := 3
@export var base_stats: Dictionary = {}
## Grenzen einzelner Stats als „Stat-ID → Vector2(Minimum, Maximum)“, z. B. höchstens 160 Radius für die Aura.
## Gelten für den fertigen Wert, also auch für spätere Upgrades und Artefakte.
@export var stat_limits: Dictionary = {}
## Wie die Waffe angreift (z. B. ProjectileBehavior)
@export var behavior: WeaponBehavior
## Wen sie angreift (z. B. NearestDistinctPicker). Fehlt er, gilt NearestDistinctPicker.
@export var target_picker: TargetPicker
## Effekte, die bei Ereignissen eingreifen (z. B. Ricochet)
@export var effects: Array[WeaponEffect] = []
## Level-Up-Upgrades dieser Waffe (Zufalls-Pool, siehe UpgradeData)
@export var upgrades: Array[UpgradeData] = []
## Bild der Waffe im Spiel als Streifen, Blick nach Osten (Frame-Anzahl = Bildbreite ÷ frame_width):
## Geschoss, kreisende Klinge oder die einzelne Flamme einer Aura
@export var projectile_texture: Texture2D
@export var frame_width := 16
@export var animation_fps := 10.0
