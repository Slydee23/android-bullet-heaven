class_name EffectData
extends Resource
## Datendatei eines Bildeffekts (data/effects/*.tres): Treffer-Funken, Tod-Staub, später Blitz-Einschlag, Explosion.
## Das Bild ist ein Streifen (Frame-Anzahl = Bildbreite ÷ frame_width), der EffectManager spielt ihn einmal ab.

## Wo der Effekt am Spielpunkt sitzt: in der Bildmitte (Treffer, Funken) oder mit dem Bildunterrand auf dem Punkt (Staub, Einschläge)
enum Anchor { CENTER, FEET }

@export var id := &""
@export var texture: Texture2D
@export var frame_width := 32
@export var fps := 12.0
@export var anchor := Anchor.CENTER
