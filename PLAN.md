# Plan: Banebound (Codename) – Bullet-Heaven für Android (Querformat)

## Status
- [x] M0 – Umstellung auf Querformat
- [x] M1 – Hauptmenü, Arena, Spielfigur, Kamera
- [ ] M2 – Touch-Steuerung, Pause, Optionen + GitHub-README
- [ ] M3 – Gegner (mit Performance-Grundlage)
- [ ] M4 – Auto-Angriff
- [ ] M5 – Debug-Menü, Stresstest & Optimierung
- [ ] M6 – XP & Level-Up
- [ ] M7 – Wellen & Run-Ende
- [ ] M8 – Run speichern & fortsetzen

## Ziel
Zuerst entsteht ein kleines, spielbares Grundspiel (Bewegen, Gegner, Auto-Angriff, Level-Up, Wellen). Danach kommen die
Erweiterungen Richtung Hades-artiger Meta-Progression. Jeder Meilenstein ist einzeln am Handy testbar und wird danach committet.

## Spielkonzept
- **Setting:** dunkle Fantasy. Die Runs sind Expeditionen zur Materialbeschaffung und Erkundung (z. B. ein Waldabschnitt).
- **Meta:** Zwischen den Runs baut man ein altes Dorf wieder auf. Dort schaltet man Gebäude frei (Schmied,
  Alchemist, Enchanter …), kauft permanente Upgrades und schaltet Charaktere, Waffen und Maps frei.
- **Rüstung:** RPG-Slots (Helm, Schultern, Brust …). Man kauft, verbessert und tauscht sie **nur zwischen den Runs**.
- **Run:** Wellen mit Shop dazwischen (Brotato-Stil), 10 bis maximal 20 Minuten. Nach der letzten Welle eines
  Levels kann es optional im Endlos-Modus weitergehen.
- **Kampf:** Angriffe laufen automatisch, dazu kommt eine **Spezialfähigkeit** (je nach Charakter oder durch Progression veränderbar).
- **Waffen:** maximal 3. Das ist eine einzige Konstante im Code und lässt sich leicht auf 4 ändern. Bei Level-Up gibt es Waffen bzw. Waffen-Upgrades. Ab Waffenlevel 10 kann man die
  Waffe in 1 von 3 Varianten weiterentwickeln, später noch einmal in 1 von 3. Daraus ergeben sich 9 Endformen pro Waffe.
- **Welt:** feste Maps (begrenzte Arena, größer als der Bildschirm), die Kamera folgt der Figur.
- **Steuerung:** Joystick Floating oder Fest, linke/rechte/beide Bildschirmseiten, einstellbare Transparenz.
- **Grafik:** 2D Fantasy Pixel-Art. Die Platzhalter sind schon in Pixel-Optik, die echte Grafik folgt später.

## Lore: Der Waffenbann
*(Namen in [eckigen Klammern] sind Platzhalter)*

> Vor langer Zeit versank die Welt im Krieg. Menschen, Elfen, Zwerge und die anderen Völker kämpften
> gegeneinander und untereinander, Generation um Generation. Am Ende gab es keine Sieger mehr, nur
> verbrannte Erde und Gräber ohne Namen.
>
> Da trat der **[Hohe Zirkel]** zusammen, der mächtigste Magierrat der Welt. In einem Ritual, das
> viele von ihnen das Leben kostete, wirkten sie **[den Bann]** auf die ganze Welt. In einer einzigen
> Nacht zerfielen alle Klingen, Bögen und Stäbe zu Staub. Ohne Waffen endete der Krieg, und der Frieden kehrte zurück.
>
> Doch der Bann ist kein vollkommenes Verbot. Er ist ein Fluch mit einer Bedingung: Gerät ein Mensch
> in größte Not, **materialisiert sich eine Waffe** in seiner Hand. Sie ist an ihn gebunden und von alter Magie
> durchdrungen. Sobald die Gefahr gebannt ist, **zerstört sie sich selbst**. Seitdem kann kein Volk mehr
> gegen ein anderes in den Krieg ziehen. Gegen die Ungeheuer, die in der Wildnis erwacht sind, kann man sich
> aber noch wehren.

**Was die Lore im Spiel erklärt:**
- Waffen gibt es **nur im Run**, sie erscheinen über die Level-Up-Auswahl. Waffen kann man nicht kaufen.
- Nach jedem Run **sind alle Waffen weg**.
- **Rüstung** ist keine Waffe und **bleibt erhalten**. Deshalb wird sie im Dorf gekauft, verbessert und getauscht.
- Gegner sind Monster und Ungeheuer, keine anderen Völker.

## Run-Ablauf: Expedition mit Rastplätzen
- Ein Run ist eine Expedition, um Materialien zu beschaffen und die Gegend zu erkunden.
- Am Ende jeder Welle findet man einen **Rastplatz** (Savezone). Dort erscheinen zufällige Händler, z. B. eine
  Karawane mit Tränkehändler und Artefakthändler.
  - **Tränke:** Verbrauchsgegenstände wie Heilung oder kurze Buffs.
  - **Artefakte:** Boni, die bis zum Ende des Runs halten.
- Bezahlt wird mit einer Währung, die man im Run sammelt (Arbeitstitel **„Magie-Schrott“**).
- Nach dem Einkauf verlässt man den Rastplatz, und die nächste Welle beginnt.
- Welche Händler es gibt und was es außer Shops noch an Rastplätzen gibt, brainstormen wir später.

## Technische Grundentscheidungen
- **Auflösung:** Viewport 1920×1080 mit Stretch `canvas_items` + Aspect `expand`. Breitere Handys (20:9) und
  Tablets zeigen etwas mehr Spielwelt, nichts wird verzerrt, und es gibt keine schwarzen Ränder.
  Das UI wird an den Rändern verankert und berücksichtigt die Safe Area (Kamera-Notch).
- **Orientation:** `sensor_landscape`. Querformat bleibt fest, und das Bild dreht sich mit, egal wie herum man das Handy hält.
- **Pixel-Art:** Die Texturen werden ohne Glättung skaliert (Filter `Nearest`) und erscheinen dadurch scharf und pixelig.
  Platzhalter-Sprites sind 16×16 bzw. 32×32 Pixel und werden im Spiel 4× vergrößert angezeigt.
  Ich erstelle sie selbst als kleine PNGs (Liste und Vorgaben siehe „Assets: Platzhalter → Alpha“).
- **Performance von Anfang an:**
  - Gegner sind **keine** Physik-Körper. Ein zentraler `EnemyManager` bewegt alle Gegner in einer einzigen Schleife.
  - Kollisionen laufen über ein **Spatial Grid**. Jeder Gegner prüft nur Objekte in den Nachbarzellen statt alle anderen.
  - **Object Pooling** für Gegner, Geschosse und XP-Kristalle: Objekte werden wiederverwendet statt
    ständig neu erzeugt und gelöscht. Das verhindert Ruckler.
  - Ein FPS-Zähler und ein Stresstest-Knopf sind ab Meilenstein 3 dabei.
  - Als spätere Option, falls nötig: Gegner per `MultiMeshInstance2D` zeichnen (Tausende in einem Draw-Call).
- **Daten statt Code:** Waffen und Gegner werden als `Resource`-Dateien (`.tres`) beschrieben, mit Werten wie Schaden,
  Tempo und Sprite. Neue Waffen, Evolutionen und Rüstungen sind dann vor allem neue Datendateien.
- **Run-Zustand und dauerhafter Zustand getrennt:** Alles, was nur im Run gilt (Waffen, Level, XP, Artefakte,
  Magie-Schrott), liegt in einem eigenen `RunState`, der nach jedem Run gelöscht wird. Dauerhaftes (Rüstung, Dorf,
  Freischaltungen) kommt später in einen separaten Spielstand. So passt die Architektur von Anfang an zur Lore.
- **Materialien (und andere Gegenstände) als Daten:** Jedes Material ist eine eigene Datei in `data/materials/`
  (z. B. `iron_ore.tres`) mit ID, Name (Übersetzungs-Schlüssel), Icon, Seltenheit, Wert und Beschreibung.
  - Ein zentrales **Register** lädt beim Start automatisch alle Dateien aus dem Ordner. Kein Code kennt eine feste Materialliste.
  - **Neues Material** = neue Datei anlegen. **Werte ändern** = Datei bearbeiten. **Entfernen** = Datei löschen.
    Am Code ändert sich dabei nichts.
  - Inventare speichern nur **ID → Anzahl**. Unbekannte IDs (z. B. von gelöschten Materialien) werden beim Laden übersprungen,
    statt den Spielstand kaputt zu machen.
  - **Crafting-Rezepte** und **Quests** sind ebenfalls Datendateien und verweisen auf Materialien („3× `iron_ore` + 1× `wolf_pelt`“).
    So hängen Materialien, Rezepte und Quests zusammen, ohne dass einer den anderen im Code kennen muss.
  - Ein Prüfskript (im Debug-Menü) meldet Rezepte oder Quests, die auf nicht mehr vorhandene Materialien verweisen.
  - Dasselbe Muster gilt später für Rüstungsteile, Artefakte, Tränke und Verzauberungen.
- **Ordnerstruktur:** `scenes/`, `scripts/`, `assets/sprites/`, `data/weapons/`, `data/enemies/`, `data/materials/`, `ui/`.

### Speicher-Architektur
Drei getrennte Dateien im App-Speicher (`user://`), jede mit eigener Versionsnummer und sicherem Schreiben:

| Datei | Inhalt | Lebensdauer | Ab |
|---|---|---|---|
| `settings.cfg` | Optionen (Joystick, Anzeige, Audio, Sprache) | dauerhaft | M2 |
| `run.save` | **Run-Spielstand:** Waffen + Level, Spielerlevel/XP, HP, Welle, Artefakte, Tränke, Magie-Schrott, im Run gesammelte Materialien, gespeicherte Shop-Angebote und Level-Up-Karten, Run-Statistik | nur während eines Runs | M8 |
| `profile.save` | **Profil-Spielstand:** Dorf-Ausbau, Material-Lager, Rüstungsbesitz + angelegte Rüstung, Verzauberungen, permanente Upgrades, Freischaltungen, Quests, Gesamtstatistik | dauerhaft, wird nie durch einen Run gelöscht | E5 |

- Der Run-Spielstand **liest** die angelegte Rüstung nur aus dem Profil (im Run kann man sie nicht tauschen) und schreibt nie hinein.
- **Belohnungsregeln:**

  | | Tod / Run aufgeben | Expedition erfolgreich |
  |---|---|---|
  | Magie-Schrott | verloren | verloren |
  | Materialien (Artefakte, Verzauberungen, Schmied, Crafting) | verloren | **ins Profil** |
  | Quest-Items und Quest-Ressourcen | verloren | **ins Profil** |
  | Bereits Freigeschaltetes, Dorf-Ausbau, Rüstung | bleibt | bleibt |

  - Während des Runs liegt die Beute nur als **„Run-Beute“** im `run.save`. Erst bei Erfolg wird sie ins Profil übertragen.
  - „Run aufgeben“ zählt wie ein Tod. Sonst könnte man kurz vor dem Tod aufgeben und die Beute retten.
- **Run-Ende (Sieg oder Tod), feste Reihenfolge:**
  1. Belohnungen nach den Regeln oben berechnen.
  2. Belohnungen ins Profil eintragen und `profile.save` sicher speichern.
  3. Erst danach `run.save` löschen.
  Stürzt die App zwischen 2 und 3 ab, merkt das Spiel beim nächsten Start an einer im Profil gespeicherten Run-ID,
  dass die Belohnung schon gutgeschrieben ist. So gibt es weder doppelte noch verlorene Belohnungen.
- Die Meta-Progression (Dorf, Rüstung, Verzauberungen, Freischaltungen) kann **durch einen Tod nie verloren gehen**,
  weil der Tod nur `run.save` betrifft.
- **Sprache:** Alle Spieltexte laufen von Anfang an über Godots Übersetzungssystem (`tr()` + Übersetzungstabelle).
  Zuerst gibt es nur Deutsch, Englisch kommt später dazu, ohne dass Code geändert werden muss.
- **PC-Test:** Am PC funktionieren zusätzlich WASD und die Pfeiltasten. F5 bleibt damit immer nutzbar.

## Assets: Platzhalter → Alpha
Ich erstelle die Platzhalter als PNG genau nach diesen Vorgaben. Für Alpha-Assets überschreibst du einfach die Datei mit
**demselben Namen am selben Ort**. Godot importiert sie dann automatisch neu, und am Code ändert sich nichts.

**Vorgaben:**
- PNG mit Transparenz, Pixel-Art ohne Anti-Aliasing, Grundraster 16×16, im Spiel 4× vergrößert.
- Animationen als horizontaler Streifen: alle Frames gleich groß, eine Datei pro Animation.
- Lizenz: CC0 oder ausdrücklich für kommerzielle Nutzung freigegeben.
- **Dateinamen auf Englisch, klein geschrieben, mit Unterstrich, ohne Umlaute und Leerzeichen**
  (z. B. `hero_run.png`, nicht `Held Laufen.png`). Android unterscheidet Groß- und Kleinschreibung,
  und Umlaute in Dateinamen machen Probleme.
- Die **Frame-Anzahl** wird automatisch aus der Bildbreite berechnet (Breite ÷ Frame-Breite). Mehr oder weniger Frames
  sind also kein Problem. Nur bei einer anderen **Frame-Größe** (z. B. 16×24 statt 16×16) sag mir Bescheid.

| Datei | Größe pro Frame | Frames | Ab |
|---|---|---|---|
| `assets/ui/menu_background.png` | 600×270 (mind. 480×270) | 1 | M1 |
| `assets/fonts/pixel_font.ttf` | – (mit ä, ö, ü, ß); noch kein Platzhalter, bis dahin Godot-Standardschrift | – | M1 |
| `assets/ui/button.png` | 16×16 (9-Slice) | 1 | M1 |
| `assets/sprites/characters/hero_idle.png` | 16×16 | 4 | M1 |
| `assets/sprites/characters/hero_run.png` | 16×16 | 6 | M1 |
| `assets/tiles/forest_ground.png` | Kacheln 16×16 in **einer Reihe** = Bodenvarianten; die erste Kachel wird am häufigsten benutzt | beliebig viele | M1 |
| `assets/tiles/forest_props.png` | Reihe aus 32×32-Zellen (Bäume, Felsen, Büsche; unten bündig) | beliebig viele | M1 |
| `assets/ui/joystick_ring.png` | 32×32 | 1 | M2 |
| `assets/ui/joystick_knob.png` | 16×16 | 1 | M2 |
| `assets/ui/pause_button.png` | 16×16 | 1 | M2 |
| `assets/ui/panel.png` | 16×16 (9-Slice, Rand 4) – Hintergrund für Menüfenster | 1 | M2 |
| `assets/ui/slider_track.png` | 12×8 (9-Slice, Rand 3) – Schieberegler-Leiste | 1 | M2 |
| `assets/ui/slider_grabber.png` | 16×16 – Schieberegler-Knopf | 1 | M2 |
| `assets/sprites/enemies/skeleton_walk.png` | 16×16 | 4 | M3 |
| `assets/sprites/characters/hero_hit.png` | 16×16 | 2 | M3 |
| `assets/sprites/characters/hero_death.png` | 16×16 | 6 | M3 |
| `assets/ui/bar_frame.png` / `bar_fill.png` | 48×8 | 1 | M3 |
| `assets/sprites/weapons/magic_bolt.png` | 8×8 | 4 | M4 |
| `assets/sprites/effects/hit.png` | 16×16 | 4 | M4 |
| `assets/sprites/effects/death.png` | 16×16 | 6 | M4 |
| `assets/sprites/pickups/xp_crystal.png` | 8×8 | 4 | M6 |
| `assets/sprites/weapons/spinning_blade.png` | 16×16 | 1 | M6 |
| `assets/sprites/weapons/fire_aura.png` | 64×64 | 8 | M6 |
| `assets/sprites/icons/weapon_magic_bolt.png` (usw. je Waffe) | 16×16 | 1 | M6 |
| `assets/ui/card_frame.png` | 32×32 (9-Slice) | 1 | M6 |
| `assets/sprites/enemies/bat_fly.png` | 16×16 | 4 | M7 |
| `assets/sprites/enemies/slime_hop.png` | 16×16 | 4 | M7 |
| `assets/ui/paperdoll.png` | Silhouette ca. 64×96 | 1 | E7 |

## Meilensteine – Grundspiel

### M0 – Umstellung auf Querformat
- `project.godot`: Viewport 1920×1080, `display/window/handheld/orientation = sensor_landscape`, Stretch
  `canvas_items`/`expand` beibehalten, Standard-Texturfilter `Nearest` (für Pixel-Art).
- `CLAUDE.md`: „Hochformat (Portrait)“ wird zu „Querformat (Landscape)“, dazu ein kurzer Konzept-Abschnitt und der Satz zu PLAN.md.
- `PLAN.md` anlegen. Danach committen und pushen.
- `export_presets.cfg` bleibt unverändert.
- **Am Handy testen:** In diesem Meilenstein noch nichts, weil es noch keine Szene gibt. Prüfe nur in Godot unter
  Projekt → Projekteinstellungen → Anzeige → Fenster, ob 1920×1080 und Landscape eingetragen sind.

### M1 – Hauptmenü, Arena, Spielfigur, Kamera
- Hauptmenü als Startszene: Titel „Banebound“ und ein Knopf „Run starten“, der in die Arena führt. Mehr kann das Menü vorerst nicht.
- Run-Szene mit einer Wald-Arena (Pixel-Bodenkacheln, Begrenzung durch Bäume oder Ränder), Held-Sprite in der Mitte,
  Kamera folgt mit Begrenzung am Arenarand. Bewegung vorerst nur per Tastatur.
- Versionsanzeige unten rechts im Hauptmenü (aus Projekteinstellungen → `application/config/version`, aktuell „Alpha v0.1“).
- Die Arena-Begrenzung durch Bäume, Büsche und Steine ist **vorläufig**. Du hast eine andere Idee für die Map-Abgrenzung,
  die Props-Texturen werden dann anderweitig verwendet. → Thema nach M7 (siehe dort).
- **Am Handy testen:** Das Spiel startet im Hauptmenü, „Run starten“ lässt sich antippen und führt in die Arena.
  Das Bild ist im Querformat und füllt den ganzen Bildschirm. Die Pixel sind scharf (nicht verschwommen).
  Das Bild dreht sich mit, wenn du das Handy umdrehst.
  **Am PC (F5):** Der Held läuft mit WASD, die Kamera folgt und bleibt am Arenarand stehen.

### M2 – Touch-Steuerung, Pause, Optionen + GitHub-README
Umsetzung in Teilschritten: 2a Joystick + Einstellungs-Grundgerüst → 2b Optionsmenü → 2c Pause-/Statusbildschirm →
2d Auto-Pause → 2e README.
- `README.md` für GitHub, geschrieben, als wäre das Spiel fertig und zum Download bereit. Aufbau orientiert an
  READMEs veröffentlichter Indie-Games: Titel, Kurzbeschreibung, Features, Lore-Teaser, Steuerung, Download, Tech-Stack, Lizenz.
- Virtueller Joystick mit zwei Modi: **Floating** (erscheint an der Daumen-Position, Standard) und **Fest** (feste Position unten).
  Dazu die Option **Seite: Links / Rechts / Beide** (Standard: Beide). Beim festen Joystick legt sie fest, ob er unten links oder
  unten rechts sitzt. „Beide“ ist beim festen Joystick ausgegraut.
- **Optionsmenü (Grundgerüst):** erreichbar aus dem Hauptmenü und aus der Pause. Erste Einträge unter Steuerung:
  Joystick-Modus, Joystick-Seite und **Joystick-Transparenz** (Schieberegler 0–80 %, 0 % = voll sichtbar).
  Einstellungen werden gespeichert (`user://settings.cfg`) und bleiben nach einem Neustart erhalten.
- **Pause-/Statusbildschirm (Grundgerüst):** Pause-Knopf oben rechts, am PC Esc, am Handy die Zurück-Geste.
  Knöpfe „Weiter“, „Optionen“ und „Run aufgeben“ (bis M8 geht der Run dabei verloren).
  Die drei Status-Spalten (siehe „UI-Konzepte“) sind schon angelegt und füllen sich ab M3.
- **Auto-Pause:** Wechselt die App in den Hintergrund (andere App, Anruf), öffnet sich automatisch das Pausemenü.
- **Am Handy testen:** Du kannst mit dem Daumen flüssig laufen, auch schräg. Probiere Modi, Seiten und Transparenz im Optionsmenü aus
  und sag mir, was sich am besten anfühlt. Schließ die App und öffne sie neu: Die Einstellungen sind noch da.
  Pause-Knopf und Zurück-Geste öffnen die Pause. Wechsle während eines Runs kurz in eine andere App:
  Beim Zurückkommen ist das Spiel pausiert.
  **Auf GitHub:** Prüfe auf der Repo-Startseite, ob die README gut aussieht und dir der Text gefällt.

### M3 – Gegner (mit Performance-Grundlage)
- `EnemyManager` mit Pooling und Spatial Grid. Gegner (z. B. Skelett) erscheinen außerhalb des Sichtfelds und laufen auf den
  Helden zu, ohne sich alle auf einen Punkt zu stapeln.
- Bei Berührung nimmt der Held Schaden. Es gibt eine Lebensleiste, und bei 0 HP kommt ein Game-Over-Bildschirm mit den Knöpfen „Nochmal“ und „Hauptmenü“.
- **Lebensleiste über dem Helden** (Option „Lebensleiste Spieler“ an/aus).
- **Treffer-Feedback beim Helden:** kurzes Bildschirmwackeln und Vibration (Optionen „Bildschirmwackeln“ und „Vibration“).
  Für Vibration braucht der Android-Export die Berechtigung VIBRATE. Das ist eine Änderung an `export_presets.cfg`, vorher fragen.
- Statusbildschirm zeigt HP.
- FPS-Anzeige in der Ecke.
- **Am Handy testen:** Die Gegner kommen von außen herein und verfolgen dich. Du verlierst Leben, Game Over und Neustart funktionieren.
  Bei Treffern wackelt das Bild und das Handy vibriert. Beides und die Lebensleiste lassen sich in den Optionen abschalten.
  Notiere dir den FPS-Wert.

### M4 – Auto-Angriff
- Erste Waffe „Magiegeschoss“: Sie schießt automatisch auf den nächsten Gegner. Geschosse kommen aus einem Pool.
  Gegner haben HP, blinken kurz bei einem Treffer und sterben (mit kleinem Effekt).
- Die Waffe ist als Resource-Datei angelegt (Grundlage für spätere Level und Evolutionen).
- **Schadenszahlen** über getroffenen Gegnern (Option „Schadenszahlen“), aus einem Pool.
- **Lebensleisten über Gegnern** (Option „Lebensleisten Gegner“). Sie erscheinen nur bei bereits verletzten Gegnern und
  werden alle in einem einzigen Zeichenaufruf des EnemyManagers gezeichnet, nicht als eigene Nodes. Das ist wichtig für die Performance.
- Statusbildschirm zeigt die Waffe mit ihren Werten.
- **Am Handy testen:** Der Held schießt von allein, Treffer und Tode sind gut zu erkennen, und das Spiel fühlt sich an wie ein Survivor-Like.
  Schadenszahlen und Gegner-Lebensleisten lassen sich einzeln abschalten.

### M5 – Debug-Menü, Stresstest & Optimierung
- **Debug-Menü** (nur in Debug-Builds sichtbar, also beim Testen aus Godot, nicht in einem späteren Release):
  FPS und Gegnerzahl, „+100 Gegner“, „Unverwundbar“. Es wächst mit: in M6 „XP geben“ und „Level-Up auslösen“,
  in M7 „Zu Welle X springen“, später z. B. „Magie-Schrott geben“.
- Mit „+100 Gegner“ messen, wie viele Gegner dein Handy bei stabilen 60 FPS schafft.
  Bei Bedarf optimieren, z. B. mit MultiMesh-Rendering oder einem gröberen Grid.
- Zielwert: mindestens **500 gleichzeitige Gegner bei 60 FPS** auf dem Testhandy **Redmi Note 13 4G** (Snapdragon 685 / Adreno 610 GPU, Display 2400×1080 = 20:9).
  Das ist untere Mittelklasse: Läuft es dort flüssig, läuft es auf den meisten Handys.
  Den Wert passen wir nach der Messung an.
- **Am Handy testen:** Spawne immer mehr Gegner und sag mir, ab welcher Anzahl es ruckelt und wie warm das Handy wird.

### M6 – XP & Level-Up
- Gegner lassen XP-Kristalle fallen, die per Magnet eingesammelt werden. Am oberen Rand gibt es eine XP-Leiste.
- Beim Level-Up pausiert das Spiel, und es erscheinen **3 Karten** zum Antippen: eine neue Waffe (maximal 3 Slots) oder
  das Upgrade einer vorhandenen Waffe.
- Im Grundspiel gibt es 3 Waffen, z. B. Magiegeschoss, kreisende Klingen und Feuer-Aura.
- Statusbildschirm zeigt Level, XP, alle Waffen-Slots mit Level und Werten sowie die Spielerwerte.
- **Am Handy testen:** Kristalle werden eingesammelt, das Level-Up-Menü lässt sich gut antippen und die Karten sind lesbar.
  Mit 3 Waffen kommen keine neuen Waffen mehr, sondern nur noch Upgrades.

### M7 – Wellen & Run-Ende
- Wellen-Timer (z. B. 60 s) mit Anzeige, z. B. „Welle 3 / 10“. Die Gegner werden pro Welle stärker und zahlreicher.
- Zwischen den Wellen gibt es einen Platzhalter-Rastplatz: eine Pause mit Wellen-Zusammenfassung und „Weiter“-Knopf.
  Die echten Händler kommen später.
- Nach der letzten Welle erscheint ein Sieg-Bildschirm, bei Tod ein Game-Over-Bildschirm. Beide zeigen die
  **Run-Zusammenfassung (Basis)** (siehe „UI-Konzepte“) und führen zurück ins Hauptmenü.
- Statusbildschirm zeigt Welle, Zeit und Kills.
- **Am Handy testen:** Ein kompletter Run lässt sich durchspielen, gewinnen und verlieren. Ist die Länge von 10–15 Minuten angenehm?
  Stimmen die Zahlen in der Zusammenfassung?
- ⚠ **Erinnerung nach Abschluss von M7:** Neue Idee für die **Map-Abgrenzung** besprechen (ersetzt den Rand aus Bäumen/Büschen/Steinen)
  und klären, wofür die Props-Texturen stattdessen verwendet werden.

### M8 – Run speichern & fortsetzen
- Die genaue technische Umsetzung planen wir zu Beginn von M8. Diese Grundsätze stehen schon fest:
  - Im Pausemenü wird „Run aufgeben“ ergänzt durch **„Speichern & Hauptmenü“**. Im Hauptmenü erscheint **„Fortsetzen“**,
    wenn ein Run gespeichert ist.
  - **Autosave nach jeder abgeschlossenen Welle** (beim Betreten des Rastplatzes).
  - **Autosave, wenn die App in den Hintergrund geht.** Android kann Apps im Hintergrund jederzeit beenden.
  - **Kein Save-Scumming:**
    - Shop-Angebote und Level-Up-Auswahlen werden beim Erzeugen mitgespeichert. Neuladen würfelt sie nicht neu.
    - Jeder Kauf wird sofort gespeichert und lässt sich durch Neuladen nicht rückgängig machen.
    - Beim Tod wird der Run-Spielstand sofort gelöscht. Wer die App kurz vor dem Tod beendet, kann sich so nicht retten.
  - **Sicheres Schreiben:** erst in eine temporäre Datei schreiben, dann ersetzen. Bei einem Absturz während des Speicherns
    bleibt so der alte Spielstand erhalten.
  - **Versionsnummer im Spielstand**, damit spätere Spiel-Updates alte Spielstände erkennen und umwandeln können.
  - **Getrennte Speicherdateien** (siehe „Speicher-Architektur“). In M8 entsteht nur der Run-Spielstand, der Profil-Spielstand kommt in E5.
- **Changelog im Hauptmenü:** Knopf „Neuigkeiten“ öffnet eine scrollbare Liste der Änderungen je Version.
  Der Inhalt steht in einer eigenen Textdatei im Projekt, damit für eine neue Version nur diese Datei ergänzt wird.
- **Am Handy testen:** Run mitten in einer Welle über „Speichern & Hauptmenü“ beenden, App ganz schließen, neu starten,
  „Fortsetzen“ funktioniert. Am Rastplatz etwas kaufen, App beenden, neu starten: Der Kauf ist noch da, die Angebote sind dieselben.
  Der Changelog lässt sich öffnen, scrollen und schließen.

➡ **Nach M8 ist das Grundspiel fertig.**

## UI-Konzepte

### Pause-/Statusbildschirm (im Run)
Drei Spalten, damit im Querformat alles auf einen Blick sichtbar ist:

| Links: Charakter | Mitte: Waffen | Rechts: Ausrüstung & Run |
|---|---|---|
| HP, Level, XP-Fortschritt | 3 Waffen-Slots: Icon, Level x/10, Evolutionsstufe und gewählter Zweig | **Paperdoll** mit angelegter Rüstung |
| Spezialfähigkeit + Abklingzeit | Werte je Waffe: Schaden, Tempo, Reichweite | Aktive Artefakte mit Beschreibung |
| Werte: Schaden %, Angriffstempo, Laufgeschwindigkeit, Krit, Rüstung, Regeneration, Sammelradius, Glück | Bisher verursachter Schaden je Waffe | Tränke im Inventar |
| | | Ausbeute: Magie-Schrott, Materialien, Kills, Zeit, Welle x/y |

Knöpfe am unteren Rand: **Weiter · Optionen · Speichern & Hauptmenü (ab M8) · Run aufgeben**.

**Paperdoll (Ausrüstungsanzeige):**
- In der Mitte steht eine humanoide Charakter-Silhouette, die Rüstungs-Slots liegen direkt an der passenden Körperstelle:
  Helm am Kopf, Schultern an den Schultern, Brust am Oberkörper, Handschuhe an den Händen, Beine an den Beinen, Stiefel an den Füßen.
- Antippen eines Slots öffnet ein Infofenster mit Name, Werten und Boni des Teils. Im Run kann man nur ansehen, nicht tauschen.
- Sie wird als **wiederverwendbare Komponente** gebaut. Das **Ausrüsten im Dorf läuft ebenfalls über die Paperdoll**:
  Slot an der Silhouette antippen → Liste der passenden Teile aus dem Besitz → auswählen → angelegt.
  Übersicht und Ausrüsten sind also derselbe Bildschirm, nur dass im Run das Tauschen gesperrt ist.
- Bis zum Rüstungssystem (E7) bleibt die Stelle leer oder zeigt nur die Silhouette.
- **Kategorien als Reiter:** Rüstung (Paperdoll), Artefakte, Tränke und spätere Kategorien. Auch die Slots sind Daten
  (Kategorie, Position an der Silhouette, erlaubte Teile). Eine neue Kategorie oder ein neuer Slot ist also eine neue Datei, kein Code.

**Performance-Regeln für Ausrüstung und Inventar:**
- **Register kennt nur die Liste, nicht den Inhalt:** Beim Start wird nur „ID → Dateipfad“ eingelesen. Eine Gegenstandsdatei
  samt Icon wird erst geladen, wenn sie gebraucht wird, und danach im Speicher behalten. Bei Tausenden Gegenständen bleibt der Start so schnell.
- **Bildschirme nur bei Bedarf:** Pause-/Status- und Ausrüstungsbildschirm werden beim Öffnen erzeugt und beim Schließen freigegeben.
  Gefüllt wird nur der aktive Reiter.
- **Lange Listen** (z. B. 300 Rüstungsteile im Besitz) zeigen nur die gerade sichtbaren Einträge und verwenden sie beim Scrollen wieder.
- **Icons klein und gebündelt:** 16×16-Icons, bei Bedarf in einem gemeinsamen Atlas (eine Textur statt vieler).
- **Im Run zählt nur das Ergebnis:** Die Werte aller angelegten Teile werden einmal am Run-Start (und bei Änderungen wie Artefakt-Kauf)
  zu einem Werte-Block zusammengerechnet. Pro Frame wird nichts aus der Ausrüstung neu berechnet.
- **Speichern nur bei Änderung:** Spielstände speichern nur IDs, Anzahlen und Verbesserungsstufen, keine Bilder oder Texte, und werden
  nur geschrieben, wenn sich etwas geändert hat.

### Optionsmenü
Erreichbar aus dem Hauptmenü und aus der Pause. Einstellungen werden gespeichert.
**Regel: Jede Option kommt im selben Meilenstein wie das Feature, das sie steuert.**

| Bereich | Option | Kommt in |
|---|---|---|
| Steuerung | Joystick-Modus (Floating / Fest) | M2 |
| Steuerung | Joystick-Seite (Links / Rechts / Beide) | M2 |
| Steuerung | Joystick-Transparenz (Schieberegler) | M2 |
| Anzeige | Lebensleiste Spieler an/aus | M3 |
| Anzeige | Bildschirmwackeln an/aus | M3 |
| Anzeige | Vibration an/aus | M3 |
| Anzeige | Schadenszahlen an/aus | M4 |
| Anzeige | Lebensleisten Gegner an/aus | M4 |
| Audio | Lautstärke Gesamt / Musik / Effekte | E2 |
| Sprache | Deutsch / Englisch | E14 |
| Steuerung | Joystick-Größe | E15 |
| Grafik | FPS-Limit 30 / 60 / 120 | E15 |

### Run-Zusammenfassung / Belohnungsbildschirm
Erscheint nach jedem Run (Sieg oder Tod) und zeigt Run-Ergebnis und langfristigen Fortschritt.
- **Basis (M7):** Kills, überstandene Wellen, Zeit, erreichtes Level, verwendete Waffen mit Level, Schaden pro Waffe.
- **Voll (E5):**
  - Run-Statistiken: Kills nach Gegnertyp, erlittener und geheilter Schaden, höchster Einzeltreffer.
  - Build-Zusammenfassung: Waffen mit Evolutionszweig, gewählte Upgrades und Werte, Artefakte.
  - Belohnungen: erhaltene Materialien und Ressourcen, was davon ins Dorf geht.
- **Quests (E9):** erhaltene Quest-Items und Questfortschritt.

## Erweiterungen (Alpha, nach M8)
Reihenfolge nach technischen Abhängigkeiten. Details planen wir jeweils zu Beginn.
1. **E1 – Rastplätze mit Händlern:** zufällige Händler (Tränke, Artefakte), Währung „Magie-Schrott“. Braucht Wellen (M7) und Speichern (M8).
2. **E2 – Audio:** Musik und Soundeffekte, Lautstärke-Optionen.
3. **E3 – Spezialfähigkeit:** aufladbar, Knopf rechts, Anzeige im Statusbildschirm.
4. **E4 – Waffen-Evolutionen:** Level 10 → 1 von 3 Varianten → 2. Evolution → 1 von 3 = 9 Endformen.
5. **E5 – Meta-Spielstand + Belohnungsbildschirm:** Profil-Spielstand (`profile.save`), Material-Register und erste Materialien
   aus Runs, volle Run-Zusammenfassung.
6. **E6 – Dorf-Hub:** Gebäude wieder aufbauen (Schmied, Alchemist, Enchanter …), NPCs, Story-Dialoge.
7. **E7 – Rüstungssystem mit Paperdoll:** im Dorf kaufen, verbessern und über die Paperdoll anlegen, im Run ansehen.
8. **E8 – Permanente Upgrades** über Dorf-Gebäude.
9. **E9 – Questsystem:** Quest-Items und Questfortschritt, Anzeige im Belohnungsbildschirm.
10. **E10 – Mehrere Charaktere** mit eigener Startwaffe und Spezialfähigkeit.
11. **E11 – Tutorial / erster Start:** braucht Level-Up, Rastplatz und Spezialfähigkeit. Den Inhalt besprechen wir vorher gemeinsam.
12. **E12 – Weitere Maps/Biome, Gegnertypen, Bosse.**
13. **E13 – Endlos-Modus** nach der letzten Welle.
14. **E14 – Englisch** + Sprach-Option.
15. **E15 – Erweiterte Optionen:** Joystick-Größe, FPS-Limit.
16. **E16 – Credits-Bildschirm.** Ab dem ersten fremden Asset führen wir `CREDITS.md` mit Quelle und Lizenz,
    damit am Ende nichts fehlt.
- **Laufend:** Alpha-Assets ersetzen die Platzhalter, sobald du sie hast.

## Beta (vor der Veröffentlichung, nicht Teil der Alpha)
- **Monetarisierung** entscheiden (Einmalkauf, Werbung, In-App-Käufe oder kostenlos). Das beeinflusst das Design, z. B. ob es
  „Wiederbeleben gegen Werbung“ gibt.
- **Play-Store-Pflichten:** App-Icon, Datenschutzerklärung (Pflicht, auch ohne Werbung), Altersfreigabe, Store-Texte, Screenshots.
- **Endgültiger Spielname**, dann Paketname (`com.slydee23.…`) und App-Namen im Export-Preset anpassen.
  Nach dem ersten Upload lässt sich der Paketname nie mehr ändern.

## Ideen (noch nicht eingeplant)
- **Headstart-Perk:** Ein Teil des Magie-Schrotts aus dem vorherigen Run wird in den nächsten Run mitgenommen.
  Wie und ob das ins Spiel kommt, ist noch offen.

## Offene Designfragen
- **Fortsetzen nach Abbruch mitten in einer Welle:** Am Anfang der Welle neu starten (einfach, so macht es Brotato) oder
  exakt an der Stelle (aufwendig)? Beim Neustart am Wellenanfang könnte man kurz vor dem Tod beenden und die Welle mit
  vollen HP vom Wellenanfang wiederholen. Ist das okay, oder braucht es eine Gegenmaßnahme? → vor M8 entscheiden
- **Magie-Schrott vs. Materialien:** Magie-Schrott = Run-Währung für Rastplatz-Händler, verfällt am Run-Ende
  (Lore-Idee: Überreste der zerfallenen Waffen). Materialien (z. B. Holz, Erz, Kräuter) = dauerhafte Beute fürs Dorf. Passt das? → vor E1
- **Endlos-Modus und Beute:** Gilt die Expedition nach der letzten regulären Welle als erfolgreich, sodass die Beute bis dahin
  schon sicher ist, und riskiert man im Endlos-Modus nur die zusätzliche Beute? → vor E13
- Welche Materialien es gibt (Liste wächst laufend, dank Daten-Dateien unkritisch) → vor E5
- Händlertypen an Rastplätzen und was es dort außer Shops noch gibt → vor E1
- Echte Namen für [Hohe Zirkel], [den Bann] und die Welt
- Details zu Dorf, Rüstung, Evolutionen → jeweils vor dem Meilenstein

## Verifikation
- Nach jedem Meilenstein: F5 am PC, danach Remote-Deploy aufs Handy (Testpunkte siehe oben).
- Erst wenn alles funktioniert: committen und pushen, `PLAN.md` abhaken bzw. aktualisieren.
- Ab M3 dient die FPS-Anzeige als Performance-Kontrolle, ab M5 kommt der Stresstest dazu.
