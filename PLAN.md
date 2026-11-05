# Plan: Bullet-Heaven für Android (Querformat)

## Status
- [x] M0 – Umstellung auf Querformat
- [ ] M1 – Arena, Spielfigur, Kamera
- [ ] M2 – Touch-Steuerung
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
  Ich erstelle sie selbst als kleine Pixel-SVGs (z. B. Held, Skelett, Fledermaus, Schleim, Magiegeschoss,
  XP-Kristall, Waldboden).
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
- **PC-Test:** Am PC funktionieren zusätzlich WASD und die Pfeiltasten. F5 bleibt damit immer nutzbar.

## Meilensteine – Grundspiel

### M0 – Umstellung auf Querformat
- `project.godot`: Viewport 1920×1080, `display/window/handheld/orientation = sensor_landscape`, Stretch
  `canvas_items`/`expand` beibehalten, Standard-Texturfilter `Nearest` (für Pixel-Art).
- `CLAUDE.md`: „Hochformat (Portrait)“ wird zu „Querformat (Landscape)“, dazu ein kurzer Konzept-Abschnitt und der Satz zu PLAN.md.
- `PLAN.md` anlegen. Danach committen und pushen.
- `export_presets.cfg` bleibt unverändert.
- **Am Handy testen:** In diesem Meilenstein noch nichts, weil es noch keine Szene gibt. Prüfe nur in Godot unter
  Projekt → Projekteinstellungen → Anzeige → Fenster, ob 1920×1080 und Landscape eingetragen sind.

### M1 – Arena, Spielfigur, Kamera
- Haupt-Szene mit einer Wald-Arena (Pixel-Bodenkacheln, Begrenzung durch Bäume oder Ränder), Held-Sprite in der Mitte,
  Kamera folgt mit Begrenzung am Arenarand. Bewegung vorerst nur per Tastatur.
- **Am Handy testen:** Das Spiel startet im Querformat und füllt den ganzen Bildschirm. Die Pixel sind scharf (nicht verschwommen).
  Das Bild dreht sich mit, wenn du das Handy umdrehst.
  **Am PC (F5):** Der Held läuft mit WASD, die Kamera folgt und bleibt am Arenarand stehen.

### M2 – Touch-Steuerung
- Virtueller Joystick mit drei Modi: Floating (linke Bildschirmhälfte, Standard), Fest (unten links) und Überall.
  Zum Umschalten gibt es vorerst ein kleines Debug-Menü, das richtige Einstellungsmenü kommt später.
- **Am Handy testen:** Du kannst mit dem Daumen flüssig laufen, auch schräg. Probiere alle 3 Modi aus und sag mir,
  welcher sich am besten anfühlt.

### M3 – Gegner (mit Performance-Grundlage)
- `EnemyManager` mit Pooling und Spatial Grid. Gegner (z. B. Skelett) erscheinen außerhalb des Sichtfelds und laufen auf den
  Helden zu, ohne sich alle auf einen Punkt zu stapeln.
- Bei Berührung nimmt der Held Schaden. Es gibt eine Lebensleiste, und bei 0 HP kommt ein Game-Over-Bildschirm mit „Nochmal“-Knopf.
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
- Zielwert: mindestens **500 gleichzeitige Gegner bei 60 FPS** auf deinem Handy. Den Wert passen wir nach der Messung an.
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
- Nach der letzten Welle erscheint ein Sieg-Bildschirm, bei Tod ein Game-Over-Bildschirm. Beide zeigen eine kleine Statistik (Kills, Zeit, Level).
- **Am Handy testen:** Ein kompletter Run lässt sich durchspielen, gewinnen und verlieren. Ist die Länge von 10–15 Minuten angenehm?

➡ **Nach M7 ist das Grundspiel fertig.**

## Erweiterungen (später, Reihenfolge flexibel)
1. Einstellungsmenü + Speichersystem (Joystick-Modus, Lautstärke, Fortschritt)
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

## Später brainstormen
- Händlertypen an Rastplätzen und was es dort außer Shops noch gibt
- Echte Namen für [Hohe Zirkel], [den Bann] und die Welt
- Details zu Dorf, Rüstung, Evolutionen (sobald das Grundspiel steht)

## Verifikation
- Nach jedem Meilenstein: F5 am PC, danach Remote-Deploy aufs Handy (Testpunkte siehe oben).
- Erst wenn alles funktioniert: committen und pushen, `PLAN.md` abhaken bzw. aktualisieren.
- Ab M3 dient die FPS-Anzeige als Performance-Kontrolle, ab M5 kommt der Stresstest dazu.
