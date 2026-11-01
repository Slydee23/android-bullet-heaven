# android-bullet-heaven

## Projekt
- Spiel: Bullet-Heaven / Survivor-Like für Android
- Hochformat (Portrait), Touch-Steuerung
- Engine: Godot 4.7.2 (Standard-Version, **nicht** .NET)
- Sprache: GDScript
- Renderer: Mobile

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
