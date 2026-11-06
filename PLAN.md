# Plan: Banebound (Codename) – Bullet-Heaven für Android (Querformat)

## Status
- [x] M0 – Umstellung auf Querformat
- [ ] M1 – Hauptmenü, Arena, Spielfigur, Kamera
- [ ] M2 – Touch-Steuerung + GitHub-README
- [ ] M3 – Gegner (mit Performance-Grundlage)
- [ ] M4 – Auto-Angriff
- [ ] M5 – Stresstest & Optimierung
- [ ] M6 – XP & Level-Up
- [ ] M7 – Wellen & Run-Ende

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
- **Steuerung:** drei Joystick-Modi (Floating, Fest, Überall), in den Einstellungen umschaltbar.
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
- **Ordnerstruktur:** `scenes/`, `scripts/`, `assets/sprites/`, `data/weapons/`, `data/enemies/`, `ui/`.
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
- **Am Handy testen:** Das Spiel startet im Hauptmenü, „Run starten“ lässt sich antippen und führt in die Arena.
  Das Bild ist im Querformat und füllt den ganzen Bildschirm. Die Pixel sind scharf (nicht verschwommen).
  Das Bild dreht sich mit, wenn du das Handy umdrehst.
  **Am PC (F5):** Der Held läuft mit WASD, die Kamera folgt und bleibt am Arenarand stehen.

### M2 – Touch-Steuerung + GitHub-README
- `README.md` für GitHub, geschrieben, als wäre das Spiel fertig und zum Download bereit. Aufbau orientiert an
  READMEs veröffentlichter Indie-Games: Titel, Kurzbeschreibung, Features, Lore-Teaser, Steuerung, Download, Tech-Stack, Lizenz.
- Virtueller Joystick mit drei Modi: Floating (linke Bildschirmhälfte, Standard), Fest (unten links) und Überall.
  Zum Umschalten gibt es vorerst ein kleines Debug-Menü, das richtige Einstellungsmenü kommt später.
- **Am Handy testen:** Du kannst mit dem Daumen flüssig laufen, auch schräg. Probiere alle 3 Modi aus und sag mir,
  welcher sich am besten anfühlt.
  **Auf GitHub:** Prüfe auf der Repo-Startseite, ob die README gut aussieht und dir der Text gefällt.

### M3 – Gegner (mit Performance-Grundlage)
- `EnemyManager` mit Pooling und Spatial Grid. Gegner (z. B. Skelett) erscheinen außerhalb des Sichtfelds und laufen auf den
  Helden zu, ohne sich alle auf einen Punkt zu stapeln.
- Bei Berührung nimmt der Held Schaden. Es gibt eine Lebensleiste, und bei 0 HP kommt ein Game-Over-Bildschirm mit den Knöpfen „Nochmal“ und „Hauptmenü“.
- FPS-Anzeige in der Ecke.
- **Am Handy testen:** Die Gegner kommen von außen herein und verfolgen dich. Du verlierst Leben, Game Over und Neustart funktionieren.
  Notiere dir den FPS-Wert.

### M4 – Auto-Angriff
- Erste Waffe „Magiegeschoss“: Sie schießt automatisch auf den nächsten Gegner. Geschosse kommen aus einem Pool.
  Gegner haben HP, blinken kurz bei einem Treffer und sterben (mit kleinem Effekt).
- Die Waffe ist als Resource-Datei angelegt (Grundlage für spätere Level und Evolutionen).
- **Am Handy testen:** Der Held schießt von allein, Treffer und Tode sind gut zu erkennen, und das Spiel fühlt sich an wie ein Survivor-Like.

### M5 – Stresstest & Optimierung
- Debug-Knopf: „+100 Gegner“. Messen, wie viele Gegner dein Handy bei stabilen 60 FPS schafft.
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
- **Am Handy testen:** Kristalle werden eingesammelt, das Level-Up-Menü lässt sich gut antippen und die Karten sind lesbar.
  Mit 3 Waffen kommen keine neuen Waffen mehr, sondern nur noch Upgrades.

### M7 – Wellen & Run-Ende
- Wellen-Timer (z. B. 60 s) mit Anzeige, z. B. „Welle 3 / 10“. Die Gegner werden pro Welle stärker und zahlreicher.
- Zwischen den Wellen gibt es einen Platzhalter-Rastplatz: eine Pause mit Wellen-Zusammenfassung und „Weiter“-Knopf.
  Die echten Händler kommen später.
- Nach der letzten Welle erscheint ein Sieg-Bildschirm, bei Tod ein Game-Over-Bildschirm. Beide zeigen eine kleine Statistik (Kills, Zeit, Level) und führen zurück ins Hauptmenü.
- **Am Handy testen:** Ein kompletter Run lässt sich durchspielen, gewinnen und verlieren. Ist die Länge von 10–15 Minuten angenehm?

➡ **Nach M7 ist das Grundspiel fertig.**

## Erweiterungen (später, Reihenfolge flexibel)
1. Einstellungsmenü + Speichersystem (Joystick-Modus, Lautstärke, Fortschritt), erreichbar über einen Knopf im Hauptmenü
2. Spezialfähigkeit (aufladbar, Knopf rechts)
3. Waffen-Evolutionen (Level 10 → 3 Varianten → 2. Evolution → 3 Varianten = 9 Endformen)
4. Rastplätze mit zufälligen Händlern (Tränke, Artefakte), Währung „Magie-Schrott“
5. Dorf-Hub: Gebäude wieder aufbauen, NPCs, Story-Dialoge
6. Rüstungssystem mit RPG-Slots (nur im Dorf)
7. Materialien und Meta-Währung aus den Runs, permanente Upgrades
8. Mehrere Charaktere mit eigener Startwaffe und Spezialfähigkeit
9. Weitere Maps/Biome und Gegnertypen, Bosse
10. Endlos-Modus nach der letzten Welle
11. Echte Pixel-Art, Sound und Musik, Effekte

## Vor dem ersten Play-Store-Upload
- Endgültigen Spielnamen festlegen, dann Paketnamen (`com.slydee23.…`) und App-Namen im Export-Preset anpassen.
  Nach dem ersten Upload lässt sich der Paketname nie mehr ändern.

## Später brainstormen
- Händlertypen an Rastplätzen und was es dort außer Shops noch gibt
- Echte Namen für [Hohe Zirkel], [den Bann] und die Welt
- Details zu Dorf, Rüstung, Evolutionen (sobald das Grundspiel steht)

## Verifikation
- Nach jedem Meilenstein: F5 am PC, danach Remote-Deploy aufs Handy (Testpunkte siehe oben).
- Erst wenn alles funktioniert: committen und pushen, `PLAN.md` abhaken bzw. aktualisieren.
- Ab M3 dient die FPS-Anzeige als Performance-Kontrolle, ab M5 kommt der Stresstest dazu.
