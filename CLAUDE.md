# android-bullet-heaven

## Projekt
- Spiel: Bullet-Heaven / Survivor-Like für Android
- Querformat (Landscape, `sensor_landscape`), Touch-Steuerung
- Engine: Godot 4.7.2 (Standard-Version, **nicht** .NET)
- Sprache: GDScript
- Renderer: Mobile
- Viewport 1920×1080, Stretch `canvas_items` + `expand` (breitere Handys zeigen mehr Welt, UI an Ränder/Safe Area verankern)
- Grafik: 2D Fantasy Pixel-Art, Texturfilter `Nearest`; Platzhalter-Sprites als kleine Pixel-SVGs

## Konzept (Kurzfassung, Details in PLAN.md)
- Dunkle Fantasy; Runs = Expeditionen in feste Maps, Wellen mit Rastplätzen (Händler) dazwischen, 10–20 min
- Auto-Angriff + Spezialfähigkeit, max. 3 Waffen (Konstante), Waffen-Evolutionen
- Lore „Waffenbann“: Waffen existieren nur im Run und verschwinden danach; Rüstung bleibt
- Meta: Dorf wieder aufbauen, Rüstungs-Slots, permanente Upgrades, Freischaltungen
- Performance: Gegner ohne Physik-Körper, zentraler EnemyManager, Spatial Grid, Object Pooling
- Run-Zustand (`RunState`) strikt getrennt vom dauerhaften Spielstand

Der aktuelle Plan steht in PLAN.md, halte ihn aktuell.

## Android-Export
- Bereits eingerichtet in `export_presets.cfg`, Paketname `com.slydee23.bulletheaven`
- `export_presets.cfg` **nicht verändern**
- Android-SDK: `D:\Android\SDK`, JDK 17 ist installiert
- Keystores, `export_credentials.cfg`, `*.apk` und `*.aab` gehören nicht ins Repo (siehe `.gitignore`)

## Testen
- Remote-Deploy aufs Handy per USB-Debugging, oder mit F5 am PC
- Godot läuft nebenbei offen: Dateien nur innerhalb des Projektordners ändern

## Arbeitsweise
- Kleine, testbare Schritte
- Vor großen Umbauten kurz nachfragen
- Nach jedem funktionierenden Schritt committen
- Der Nutzer ist Anfänger: nach jeder Änderung kurz erklären, was geändert wurde, und sagen, was in Godot getestet werden soll
