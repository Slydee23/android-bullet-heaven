class_name EffectData
extends Resource
## Datendatei eines Bildeffekts (data/effects/*.tres): Treffer-Funken, Tod-Staub, später Blitz-Einschlag, Explosion.
## Das Bild ist ein Streifen (Frame-Anzahl = Bildbreite ÷ frame_width), der EffectManager spielt ihn einmal ab.

## Wo der Effekt am Spielpunkt sitzt: in der Bildmitte (Treffer, Funken) oder mit dem Bildunterrand auf dem Punkt (Staub, Einschläge)
## PIVOT: der Punkt `pivot` im Bild liegt auf dem Spielpunkt (z. B. der Held beim Peitschenhieb, das Bild wird darum gedreht)
enum Anchor { CENTER, FEET, PIVOT }

@export var id := &""
@export var texture: Texture2D
@export var frame_width := 32
@export var fps := 12.0
@export var anchor := Anchor.CENTER
## Drehpunkt im Bild (Pixel, nur bei Anchor.PIVOT)
@export var pivot := Vector2.ZERO
