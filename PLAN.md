# Plan: Banebound (Codename) – Bullet-Heaven für Android (Querformat)

## Status

- [x] M0 – Umstellung auf Querformat
- [x] M1 – Hauptmenü, Arena, Spielfigur, Kamera
- [x] M2 – Touch-Steuerung, Pause, Optionen + GitHub-README
- [x] M3 – Gegner (mit Performance-Grundlage) + Debug-Menü-Grundgerüst
- [x] M4 – Auto-Angriff (6 Startwaffen, Status-Effekte, Schadenszahlen, Statusbildschirm)
- [x] M5 – Debug-Menü erweitern, Stresstest & Optimierung
- [ ] M6 – XP & Level-Up
- [ ] M7 – Wellen & Run-Ende
- [ ] M8 – Run speichern & fortsetzen

## Ziel

Zuerst entsteht ein kleines, spielbares Grundspiel (Bewegen, Gegner, Auto-Angriff, Level-Up, Wellen). Danach kommen die
Erweiterungen Richtung Hades-artiger Meta-Progression. Jeder Meilenstein ist einzeln am Handy testbar und wird danach committet.

## Spielkonzept

- **Setting:** dunkle Fantasy. Die Runs sind Expeditionen zur Materialbeschaffung und Erkundung (z. B. ein Waldabschnitt).
- **Meta:** Zwischen den Runs baut man ein altes Dorf wieder auf. Dort schaltet man Gebäude frei (Schmied,
  Alchemist, Enchanter …), kauft permanente Upgrades und schaltet Spezialfähigkeiten, Startwaffen und Maps frei.
- **Ein spielbarer Held:** Es gibt nur den Hauptcharakter, keine Charakterauswahl. Abwechslung entsteht über
  Spezialfähigkeiten und Startwaffen, die man im Dorf freischaltet und vor einer Expedition wählt.
- **Rüstung:** RPG-Slots (Helm, Schultern, Brust …). Man kauft, verbessert und tauscht sie **nur zwischen den Runs**.
- **Run:** Wellen mit Shop dazwischen (Brotato-Stil), 10 bis maximal 20 Minuten. Nach der letzten Welle eines
  Levels kann es optional im Endlos-Modus weitergehen.
- **Kampf:** Angriffe laufen automatisch, dazu kommt eine **Spezialfähigkeit**. Neue Fähigkeiten schaltet man bei einem
  NPC im Dorf frei, dort wählt man auch vor dem Run eine aus. Während des Runs ist sie fest.
- **Waffen:** **4 Plätze: 1 Startwaffen-Platz + 3 Run-Plätze** (zwei Konstanten im Code: `START_SLOTS`, `RUN_SLOTS`). Die Startwaffe zählt nicht zu den 3 Run-Plätzen,
  leveln und entwickeln sich aber alle Waffen gleich. Bei Level-Up gibt es Waffen bzw. Waffen-Upgrades. Ab Waffenlevel 10 kann man die
  Waffe in 1 von 3 Varianten weiterentwickeln, später noch einmal in 1 von 3. Daraus ergeben sich 9 Endformen pro Waffe.
- **Startwaffe:** Jeder Run beginnt mit **genau 1 Startwaffe** (das bleibt immer so). Am Anfang ist sie fest, weitere
  Startwaffen werden im Laufe des Spiels freigeschaltet und vor der Expedition im Hub gewählt (jederzeit änderbar). Die Startwaffe belegt den
  Startwaffen-Platz und ist ab Welle 1 da. Alle weiteren Waffen kommen über Level-Up in die 3 Run-Plätze.
  **Startwaffen sind nicht stärker als andere Waffen** (kein Bonus): Die Wahl hilft nur, einen gewünschten Build leichter zu erreichen.
- **Waffenidentität:** Jede Auswahl ist eine **echte Fantasy-Waffe** (Zauberstab, Schwert, Dreizack …), keine abstrakte Fähigkeit.
  Die **Fähigkeit der Waffe bestimmt ihr Angriffsverhalten**. Upgrades verbessern oder verändern Eigenschaften und Effekte der Waffe.
  Auswahl und Spielgefühl orientieren sich an Vampire Survivors, die Darstellung ist thematisch.
- **Waffen-Pool:** **6 Waffen sind von Anfang an freigeschaltet** (Richtwert, später anpassbar), weitere schaltet man über Fortschritt oder
  Aktivitäten im Hub frei. Aus den freigeschalteten Waffen wählt man die Startwaffe und bekommt per Level-Up weitere.
  Jede dieser Waffen muss auch allein in Welle 1 funktionieren und sich durch Angriffsmuster und Spielweise von den anderen unterscheiden.
- **Start-Waffen (Vorschlag, bestätigt):** Arkaner Zauberstab (gezielte Geschosse), Kreisendes Schwert (Orbit), Dreizack (zufällige Blitze),
  Flammenfackel (Aura), Peitsche (Sichel-Schlag in 4 Richtungen), Bombenbeutel (Zufalls-Bomben mit Warnfläche).
  Später freischaltbar (Vorschläge): Giftphiole (Giftwelle), Frostbogen (durchdringende Eispfeile), Wurfscheibe (Ricochet).
- **Elemente und Status-Effekte:** Physisch, Feuer (Burning), Blitz (Shock = Kettenblitz), Gift (Poisoned, stapelt), Kälte (Frost = Slow, Freeze eventuell als Extra-Effekt einer Entwicklung). Siehe Grundsatz 9.
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
- **Startwaffe:** Zu Beginn jeder Expedition materialisiert sich eine Waffe. Freigeschaltet wird nur, *welche* Waffe das ist.
  Auch sie existiert nur im Run und verschwindet danach.
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
  **Sprite-Auflösung 32×32** (nach Vergleichstest am Handy entschieden, Größe „1,5×“): Figuren sind 32×32, Bodenkacheln 32×32,
  Props 64×64. Die Kamera zeigt sie mit Zoom 3× (Nah) bis 2× (Weit), eine Figur ist also 96 bis 64 Bildschirmpixel hoch (2× am Handy getestet: Bei beiden Endstufen sind die Pixel ganzzahlig und ganz scharf).
  Weil diese Zoomstufen nicht immer ganzzahlig sind, nutzen Held und Gegner den **Sharp-Pixel-Shader**
  (`assets/shaders/sharp_pixel_material.tres`, Texturfilter „Linear“): Alle Pixel bleiben gleich breit und flimmern nicht.
  Boden und Props vorerst ohne Shader (bei Kachel-Atlanten würden sonst Nachbarkacheln an den Rändern durchscheinen); Prüfpunkt in M5.
  UI-Texturen bleiben klein und werden 4× vergrößert.
  Ich erstelle sie selbst als kleine PNGs (Liste und Vorgaben siehe „Assets: Platzhalter → Alpha“).
- **Performance von Anfang an:**
  - Gegner sind **keine** Physik-Körper. Ein zentraler `EnemyManager` bewegt alle Gegner in einer einzigen Schleife.
  - Kollisionen laufen über ein **Spatial Grid**. Jeder Gegner prüft nur Objekte in den Nachbarzellen statt alle anderen.
  - **Object Pooling** für Gegner, Geschosse und XP-Kristalle: Objekte werden wiederverwendet statt
    ständig neu erzeugt und gelöscht. Das verhindert Ruckler.
  - Ein FPS-Zähler und ein Stresstest-Knopf sind ab Meilenstein 3 dabei.
  - Als spätere Option, falls nötig: Gegner per `MultiMeshInstance2D` zeichnen (Tausende in einem Draw-Call).
- **Code-Regeln** (Details in CLAUDE.md): Funktionsparameter und Rückgabewerte immer typisiert. Häufige Objekte kommen aus Pools,
  Massenobjekte werden zentral gezeichnet. Menüs dürfen beim Öffnen erzeugt werden.
- **Daten statt Code:** Waffen und Gegner werden als `Resource`-Dateien (`.tres`) beschrieben, mit Werten wie Schaden,
  Tempo und Sprite. Neue Waffen, Evolutionen und Rüstungen sind dann vor allem neue Datendateien.
  Spezialfähigkeiten genauso: `SpecialAbilityData` in `data/abilities/` (ID, Name, Icon, Abklingzeit, Freischalt-Kosten),
  automatisch geladen über ein Register wie bei den Materialien.
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
| --- | --- | --- | --- |
| `settings.cfg` | Optionen (Joystick, Anzeige, Audio, Sprache) | dauerhaft | M2 |
| `run.save` | **Run-Spielstand:** Waffen pro Platz (ID, Level, gewählte Upgrades/Effekte, Evolutionszweig), Spielerlevel/XP, HP, Welle, Artefakte, Tränke, Magie-Schrott, im Run gesammelte Materialien, gespeicherte Shop-Angebote und Level-Up-Karten, Run-Statistik, gewählte Spezialfähigkeit und Startwaffe (IDs) | nur während eines Runs | M8 |
| `profile.save` | **Profil-Spielstand:** Dorf-Ausbau, Material-Lager, Rüstungsbesitz + angelegte Rüstung, Verzauberungen, permanente Upgrades, Freischaltungen (u. a. freigeschaltete Spezialfähigkeiten und Startwaffen als IDs, dazu die jeweils gewählte), Quests, Gesamtstatistik | dauerhaft, wird nie durch einen Run gelöscht | E5 |

- Der Run-Spielstand **liest** die angelegte Rüstung nur aus dem Profil (im Run kann man sie nicht tauschen) und schreibt nie hinein.
  Genauso werden gewählte Spezialfähigkeit und Startwaffe beim Run-Start ins `run.save` kopiert und im Run nicht geändert.
- **Belohnungsregeln:**

  | | Tod / Run aufgeben | Expedition erfolgreich |
  | --- | --- | --- |
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

## Grundsatzentscheidungen

Gemeinsam festgelegt, bevor das Kampfsystem entsteht. Änderungen daran nur nach Absprache.

1. **Perspektive: Low Top-Down (3/4-Ansicht)**, wie Vampire Survivors oder Stardew Valley.
   - Nur **2 Blickrichtungen**: Sprites schauen nach rechts (bzw. schräg nach vorne rechts), links ist gespiegelt. Keine Animationen nach oben/unten.
   - **Kollisionskreis an den Füßen**, nicht in der Sprite-Mitte. Dass sich Köpfe überlappen, ist gewollt.
   - Der **Held wird immer über den Gegnern** gezeichnet. Gegner untereinander werden nach Höhe sortiert (pro Pixelzeile, ohne neue Arrays): Wer weiter unten steht, verdeckt die dahinter.
   - Keine Höhenstauchung: Reichweiten sind echte Kreise.
2. **Kamera-Zoom: Dynamisch ist der Standard** (am PC und am Handy getestet). Nah (3×) und Weit (2×) bleiben im Debug-Menü zum Vergleichen.
   - Dynamisch: Jede Wave startet bei 3×. Mit steigender Gegnerzahl zoomt die Kamera fließend bis maximal 2× heraus
     (mehr Übersicht, wenn Waffen, Reichweiten und Gegnerzahl wachsen).
   - Innerhalb einer Wave zoomt sie nur heraus, nie wieder herein (kein „Pumpen“ beim Töten). Zurück auf 3× zur nächsten Wave.
   - **Ab 50 lebenden Gegnern ist der Zoom immer ganz draußen (2×)**, fest und unabhängig von den Waves
     (am Handy getestet: ab 50 Gegnern ist der Bildschirm voll genug).
   - (Bis zur 32×32-Umstellung waren es 4× bis 3× mit 16×16-Figuren. Auf dem Bildschirm sind die Figuren jetzt 1,5× so groß.)
   - Zwischenstufen sind nicht ganzzahlig, deshalb der Sharp-Pixel-Shader für Held und Gegner (siehe „Technische Grundentscheidungen“).
3. **Rüstung ist nicht an der Spielfigur sichtbar**, sondern nur in Paperdoll und Icons (siehe „Ideen“ für ein mögliches Update).
4. **Assets:** kostenlose Assets, KI-Tools (z. B. Pixellab) und selbst erstellte Platzhalter gemischt.
   - **Pixellab ist bevorzugte Quelle:** Laut Nutzungsbedingungen (Punkt 1.3) gehören uns die Rechte an allen damit erstellten
     Grafiken, kommerzielle und nicht kommerzielle Nutzung ohne Genehmigung (vom Nutzer am 2026-11-09 geprüft).
   - Lizenz je fremdem Asset prüfen und in `CREDITS.md` eintragen (dort stehen auch Engine und Pixellab).
   - **Feste Farbpalette und feste Sprite-Größen**, damit Assets aus verschiedenen Quellen zusammenpassen.
     Die Palette steht in `tools/palette.gd` (aus Held und Skelett gelesen, M4a+), alle Generatoren der Spielwelt nutzen sie.
     Neue Farben (Feuer, Gift, Frost …) dürfen aufgenommen werden, wenn sie zu Sättigung und Helligkeit der vorhandenen passen. Vorher frage ich den Nutzer.
   - **Generator-Grafiken sind vollwertige Assets.** Was der Nutzer abgenommen hat, bleibt final und wird nicht ersetzt. Die Generatoren
     unter `tools/` bleiben im Repo, damit jede Grafik reproduzierbar und anpassbar ist. Neue Effekte und Geschosse erzeugt standardmäßig
     ein Generator, Pixellab ist vor allem für Figuren gedacht. **Vor jeder neuen Grafik frage ich den Nutzer nach Details** (Form, Farben,
     Stimmung, Größe im Spiel, Vorbilder), damit sie genau zum Rest passt.
5. **Kollision und Schaden:**
   - Der Held kann **durch Gegner hindurchlaufen**. Gegner bleiben am Rand seines Körperradius stehen, nicht in ihm, und werden
     beiseitegeschoben, wenn er durch eine Gruppe läuft. Gegner können den Helden nie einsperren.
   - Gegner verursachen **Kontaktschaden**. Jeder Gegnertyp hat eine Angriffsreichweite (`attack_range`, Nahkampf = Berührung)
     und ein Angriffsintervall (`attack_interval`). Fernkämpfer bleiben später einfach weiter weg stehen.
   - **I-Frames nach einem Treffer sind fest eingeplant** (im Test fühlte sich das Spiel ohne sie merkwürdig an), der Held blinkt dabei.
     Die Dauer hängt am Schaden, Formel wie in Brotato: `Dauer = 0,4 s × Schadensanteil an Max-HP ÷ 15 %`, begrenzt auf 0,2–0,4 s.
     Es zählt der tatsächlich erlittene Schaden nach Rüstung. Formel und Grenzen liegen nur in `IFrameRule` (`data/combat/player_iframes.tres`).
     Am Handy getestet: Das Blinken bleibt sichtbar, die Werte bleiben vorerst so. Feinabstimmung beim allgemeinen Balancing (Regler im Debug-Menü).
   - **Das Angriffsintervall gilt immer:** Ein einzelner Gegner trifft nur alle `attack_interval` Sekunden, viele Gegner zusammen so oft, wie
     die I-Frames es erlauben. Die Gefahr wächst also mit der Gegnerzahl.
   - **Selbstschaden** (`take_self_damage`) wirkt auch während der I-Frames und löst keine aus.
     Vorläufig tötet er nicht (bleibt bei 1 HP). Endgültig entscheiden wir das beim ersten Effekt, der ihn nutzt.
6. **Werte-System (Stats):**
   - Jeder Wert (Schaden, Angriffstempo, Rüstung …) ist eine **Stat-Definition** als Datendatei mit Mindest- und Höchstwert.
   - Alles, was Werte verändert (Level-Up, Artefakt, Rüstung, Dorf-Upgrade, Status-Effekt), liefert **Modifikatoren**
     (Stat, Art, Wert). Arten: fest (FLAT), Prozent (PERCENT), Sonder-Multiplikator (MULT).
   - Ein **StatBlock** rechnet: `Endwert = (Grundwert + Σ FLAT) × (1 + Σ PERCENT) × Π MULT`, begrenzt auf Min/Max.
   - Boni derselben Art **addieren** sich (+20 % und +15 % = +35 %). MULT nur für seltene Quellen (z. B. Evolutionen).
   - Verteidigung mit **abnehmendem Ertrag**: Schadensreduktion = `Rüstung ÷ (Rüstung + K)` (z. B. K = 15). Dazu Obergrenzen
     in den Stat-Definitionen (z. B. Ausweichen max. 60 %).
   - **Schadens-Tags** (z. B. `projectile`, `melee`) und **Elemente** (`physical`, `fire`, `lightning`, `poison`, `cold`), damit Boni nur bestimmte Waffen betreffen können.
     Jede Waffe hat genau ein Element, `physical` (Anzeige „Physisch“) ist der Standard für Waffen ohne Element.
   - **Zusätzliche Projektile:** Stat `amount` (Anzahl der Angriffseinheiten pro Angriff, Grundwert in der Waffe) plus globaler Bonus `extra_projectiles`,
     der nur Waffen mit `amount`-Unterstützung betrifft (siehe Grundsatz 9).
   - Neu gerechnet wird nur bei Änderungen. Geschosse tragen ihren fertigen Schadenswert.
   - Beispiel: Arkaner Zauberstab 10 Grundschaden, +3 durch Waffenlevel, Artefakt +20 %, Rune +15 % → (10 + 3) × 1,35 = 17,6.
   - Einbau schrittweise: Grundschaden in M4, StatBlock und Modifikatoren in M6.
     Waffen lesen ihre Werte aber von Anfang an über `WeaponInstance.get_stat(id)`, damit M6 nur das Innere austauscht (siehe Punkt 9).
7. **Zielen:** Gespielt wird mit einem Daumen, kein zweiter Stick.
   - Der **Zielmodus ist eine Eigenschaft der Waffe** (Datendatei) und ein austauschbarer Baustein (`TargetPicker`, siehe Grundsatz 9):
     `NEAREST_DISTINCT` (nächste Gegner, jeder nur einmal, Standard), `RANDOM_ENEMY`, `RANDOM_SCREEN_POINT`, `RANDOM_DIRECTION`,
     `FACING` (letzte Laufrichtung, stufenlos, nicht nur links/rechts), später z. B. `STRONGEST`, `DENSEST`.
     Ein Upgrade oder eine Entwicklung kann den Zielmodus wechseln (z. B. Bomben zielen auf Gegnergruppen).
   - **Kein Homing:** Geschosse sind nur beim Abschuss gezielt. Lenken im Flug kann später ein Upgrade-Effekt sein.
   - Bewusst **kein vom Spieler umschaltbarer Zielmodus**: Der Zielmodus macht jede Waffe einzigartig und situativ.
8. **Begehbare Hub-Stadt** als Zentrum des Spiels (siehe „Hub-Stadt“). Die Architektur wird schon jetzt darauf vorbereitet:
   - **Zentrale Szenensteuerung** (Autoload `SceneRouter`) für Hauptmenü, Run und später Hub/Innenräume. Kommt in M3b.
   - **Der Held hat keine Waffen eingebaut.** Er kann laufen, hat HP und Animationen. Waffen hängt nur der Run als eigenen
     Baustein an (M4). So läuft derselbe Held auch durch die Stadt, wo der Bann Waffen verhindert.
   - **Der Run bekommt Parameter** (`ExpeditionData`: Map, Wellen, Beute) statt fest verdrahteter Werte. Kommt in M7.
   - Später (mit der Map-Rand-Diskussion nach M7): Hindernis-Kollision für den Helden (`CharacterBody2D`). Gegner bleiben
     physikfrei und meiden blockierte Grid-Zellen.

9. **Waffen-Architektur (flexibel erweiterbar):** Eine Waffe besteht aus drei austauschbaren Teilen. Neue Waffen und Mechaniken sind
   meist neue Datendateien oder kleine Zusatz-Skripte, kein Umbau.
   - **`WeaponData` (Resource):** Name, Icon, Tags (`projectile`, `magic` …), Zielmodus, **Grundwerte als Liste „Stat-ID → Wert“**
     (damage, cooldown, range, projectile_speed, pierce, amount …; ein neuer Stat ist nur eine neue Zeile in der Datendatei),
     `behavior` (wie die Waffe angreift: Geschoss, kreisende Klinge, Aura; ein Skript pro Angriffsart) und `effects`
     (Effekte, die bei Schuss, Treffer oder Kill eingreifen, z. B. Ricochet = Treffer-Effekt, später Brennen, Explosion).
   - **`WeaponInstance` (nur im Run):** Datendatei, Level, gewählte Upgrades (= Modifikatoren) und zusätzliche Effekte.
     `get_stat(id)` liefert den fertigen Wert: in M4 der Grundwert, ab M6 rechnet hier der StatBlock. Geschosse tragen ihren fertigen Schaden.
   - **`WeaponHolder` (Baustein der Run-Szene):** `START_SLOTS := 1`, `RUN_SLOTS := 3`, dazu `can_add_run_weapon()` und `has_weapon(id)` für den Level-Up-Pool.
   - **Performance:** Geschosse bleiben im Pool des `ProjectileManager` (merken sich nur den Waffen-Index). Effekte laufen nur bei Ereignissen
     (Treffer, Kill), nicht pro Frame. Waffen ohne Effekte kosten nichts extra.
   - Evolutionen (E4) sind neue Waffen-Datendateien, die die alte im selben Platz ersetzen. Sie können Element, Status-Effekt und `TargetPicker`
     wechseln (geplant: elementare Zauberstab-Entwicklungen, brennende Schwerter, Bleeding bei physischen Waffen, Bomben auf Gegnergruppen).
   - **Fünf Angriffsarten (`WeaponBehavior`)** decken alle geplanten Muster ab:
     `ProjectileBehavior` (gezielte, durchdringende, abprallende Geschosse und Wellen mit unbegrenztem Durchschlag),
     `OrbitBehavior` (umlaufende Klingen), `AuraBehavior` (Dauerfläche um den Helden), `StrikeBehavior` (Einschläge: Blitze, Bomben mit Verzögerung),
     `SweepBehavior` (Richtungsangriffe wie die Sichel der Peitsche). Haken: `fire()` (bei Abklingzeit), `tick(delta)` (Dauerwaffen), `on_stats_changed()`.
     Verweise (Held, Gegner, Geschosse, Effekte) stecken in einem gemeinsamen `WeaponContext`.
   - **`TargetPicker`** wählt Ziele bzw. Richtungen und wird in der `WeaponInstance` gehalten (austauschbar durch Upgrades).
   - **Zusätzliche Projektile (`amount`):** Die Behavior ruft pro Angriff `amount`-mal den `TargetPicker` auf (mit den schon gewählten Zielen), jede Einheit folgt also
     dem Muster ihrer Waffe, nie einem festen Fächer. Alle Einheiten lösen **gleichzeitig** aus, nur überzählige Geschosse (mehr Geschosse als Gegner)
     folgen als kurze Salve (0,1 s Abstand, **reihum auf die schon gewählten Ziele**, Reihenfolge nächster, zweitnächster, nächster …). Wirkung von +1: Zauberstab ein weiteres Geschoss auf ein weiteres Ziel,
     Schwert eine weitere Klinge, Dreizack ein weiterer Blitz (ohne weiteren Gegner: zufälliger Punkt im Bild), Bomben eine weitere Bombe,
     Peitsche ein weiterer Schlag in einer anderen Richtung, Aura nicht anwendbar (`supports_stat`).
     **Peitsche:** Der erste Schlag geht in eine zufällige der 4 Himmelsrichtungen. Zusätzliche Schläge gehen **zuerst auf die gegenüberliegende Seite,
     danach zum „+“ (die übrigen zwei Himmelsrichtungen) und erst dann in die Diagonalen (maximal 8).
   - **Treffer-Formen im EnemyManager** (Spatial Grid, ohne Allokation): `damage_in_radius`, `damage_in_crescent` (Sichel = innerhalb eines großen Kreises,
     außerhalb eines versetzten zweiten Kreises), bei Bedarf `damage_in_rect`. Der `ProjectileManager` bekommt die Bewegungsart `ORBIT`, einen
     Treffer-Takt pro Gegner für Dauerwaffen und einen Erinnerungsspeicher der zuletzt getroffenen Gegner (Durchschlag, Ricochet).
   - **Stabile Gegner-IDs:** Gegner behalten eine fortlaufende ID (`_ids`), weil beim Tod der letzte Gegner nachrückt und Plätze sich ändern.
     Geschosse und Status-Effekte merken sich IDs statt Plätzen.
   - **`EffectManager`** (ab M4b): Treffer-, Tod- und Einschlag-Visuals, ein Pool, ein Zeichenaufruf, dazu verzögerte Ereignisse (Bombenzünder)
     mit **Warnfläche** (leicht transparent, genau in Explosionsgröße, nicht ablenkend).
   - **Status-Effekte (`StatusEffectData`)**: Element, Art, Dauer, Stärke, Stapelregel, Farbe. Arten: `DOT`, `SLOW`, `STOP`, `CHAIN` (Kettenblitz).
     Burning = DOT (Dauer erneuern), Poisoned = DOT (stapelt), **Shock = Kettenblitz** (`CHAIN`, entschieden: ein geschockter Gegner gibt einen Teil des erlittenen
     Schadens als Blitz an nahe Gegner weiter; Upgrades dafür später: mehr Ziele, mehr % Schaden beim Überspringen), **Frost = Slow** (`SLOW`),
     Freeze = STOP (eventuell später als Extra-Effekt einer Entwicklung), Bleeding (später, physisch) = DOT. Angewendet über `ApplyStatusEffect` (ein `WeaponEffect`).
     Speicher pro Gegner als Bitmaske und flache Arrays, nur Gegner mit gesetzter Maske laufen durch die Status-Schleife.
     Später: Resistenzen/Immunitäten je `EnemyData`, Elementreaktionen, Status auf den Helden.
   - **Freischalten:** `WeaponData.default_unlocked` (später zusätzlich eine Freischalt-ID). Level-Up-Pool und Startwaffen-Auswahl ziehen nur aus freigeschalteten Waffen
     (`WeaponCatalog`; die Liste der freigeschalteten IDs liegt später im Profil-Spielstand).
   - **Upgrades (M6):** zufälliger Pool je Waffe (`WeaponUpgrade`: Modifikatoren, optional zusätzliche Effekte, `max_stacks`, Gewicht, Voraussetzungen).
     Waffenlevel = 1 + Anzahl gewählter Upgrades (Obergrenze 10, dann Evolution). Die Waffe wird nicht am Helden gezeichnet (später evtl. schwebend wie bei Brotato, siehe „Ideen“).

## Assets: Platzhalter → Alpha

Ich erstelle die Platzhalter als PNG genau nach diesen Vorgaben. Für Alpha-Assets überschreibst du einfach die Datei mit
**demselben Namen am selben Ort**. Godot importiert sie dann automatisch neu, und am Code ändert sich nichts.

**Vorgaben:**

- PNG mit Transparenz, Pixel-Art ohne Anti-Aliasing. **Grundraster 32×32** für Spielwelt-Sprites (seit der Umstellung in M3),
  UI-Texturen bleiben klein (16er-Raster, im Spiel 4× vergrößert).
- Figuren schauen **nach rechts (Osten)**, links wird automatisch gespiegelt. Keine Animationen nach oben/unten
  (siehe Grundsatzentscheidung 1). Die Füße stehen unten bündig im Frame.
- Animationen als horizontaler Streifen: alle Frames gleich groß, eine Datei pro Animation.
- Lizenz: CC0 oder ausdrücklich für kommerzielle Nutzung freigegeben (bei KI-Tools die Nutzungsbedingungen des Tarifs prüfen).
  Jedes fremde Asset kommt mit Quelle und Lizenz in `CREDITS.md`.
- Farben aus der gemeinsamen Palette `tools/palette.gd`. Neue Farben dürfen aufgenommen werden, wenn sie zu Sättigung und Helligkeit passen.
- **Stilleitfaden für Generator-Grafiken:** nur Palettenfarben, dunkler 1-px-Rand bei Effekten, die sich vom Boden abheben müssen,
  Licht von oben links, gleiche Pixeldichte wie Held und Skelett, Effekte kurz (4–6 Bilder).
- **Status der Dateien:** **Final** = bleibt, **Final-Kandidat** = gefällt, Feinschliff möglich, **Platzhalter** = wird ersetzt.
  Pixellab-Grafiken und abgenommene UI-Texturen gelten als Final, die übrigen Generator-Grafiken als Final-Kandidat. Ausnahmen:
  `hero_hit.png`, `hero_death.png` und `forest_props.png` sind Platzhalter.
- **Neue Grafiken müssen zum Stil der vorhandenen passen und dürfen nicht wie Fremdkörper wirken.** Vorzugsgröße **32×32**, andere Größen nur,
  wenn sie sinnvoller sind. Wichtiger als die Auflösung ist die **gleiche Pixeldichte**: Ein 16×16-Geschoss ist im Spiel genauso grob gepixelt wie der 32×32-Held.
  Einheitlicher Pixel-Art-Stil, gleiche Lichtrichtung und Umrandung wie bei Held und Skelett.
- **Dateinamen auf Englisch, klein geschrieben, mit Unterstrich, ohne Umlaute und Leerzeichen**
  (z. B. `hero_run.png`, nicht `Held Laufen.png`). Android unterscheidet Groß- und Kleinschreibung,
  und Umlaute in Dateinamen machen Probleme.
- Die **Frame-Anzahl** wird automatisch aus der Bildbreite berechnet (Breite ÷ Frame-Breite). Mehr oder weniger Frames
  sind also kein Problem. Nur bei einer anderen **Frame-Größe** (z. B. 32×48 statt 32×32) sag mir Bescheid.

| Datei | Größe pro Frame | Frames | Ab |
| --- | --- | --- | --- |
| `assets/ui/menu_background.png` | 600×270 (20:9, im Spiel genau 4× vergrößert; mind. 480×270) – Nacht über einem Waffenfeld, Mond mit Bann-Siegel | 1 | M1 |
| `assets/fonts/pixel_font.ttf` | Jersey 10 (SIL OFL, siehe `CREDITS.md`, auf 16er-Raster angepasst), mit ä, ö, ü, ß und klaren Ziffern. Größen 32/48/64/96/128 sind gestochen scharf | – | M1 |
| `assets/ui/button.png` | 20×20 (9-Slice, Rand 6) – Runentafel mit Goldkante | 1 | M1 |
| `assets/ui/button_pressed.png` | 20×20 (9-Slice, Rand 6) – gedrückt/gewählt, violett glühend | 1 | M3 |
| `assets/ui/divider.png` | 96×9 – goldene Trennlinie unter Überschriften | 1 | M3 |
| `assets/sprites/characters/hero_idle.png` | 32×32, Blick nach Osten (Pixellab) | 1 (später gern Atem-Animation, beliebig viele) | M1 |
| `assets/sprites/characters/hero_run.png` | 32×32, Blick nach Osten (Pixellab) | 8 (beliebig) | M1 |
| `assets/tiles/forest_ground.png` | **Nahtloses Bodenmuster** aus 32×32-Kacheln (jetzt 512×512 = 16×16 Kacheln, ca. 15 % Erdflecken mit verzerrten, unregelmäßigen Formen). Jede Zelle nimmt die Kachel an ihrer Position im Muster, das Muster wird pro Run zufällig verschoben. Beliebig groß, solange Breite und Höhe Vielfache von 32 sind und das Bild als Ganzes nahtlos ist | 1 Muster | M1 |
| `assets/tiles/forest_ground_details.png` | Reihe transparenter 32×32-Details (Steine, Laub, Pilze, Blumen …), zufällig auf ca. 10 % der Kacheln | beliebig viele | M3 |
| `assets/tiles/forest_canopy.png` | Nahtloses, dichtes Kronendach aus 32×32-Kacheln (jetzt 128×128), füllt alles außerhalb der begehbaren Fläche | 1 Muster | M3 |
| `assets/tiles/forest_edge.png` | Reihe transparenter 32×32-Waldrand-Stücke, Fußpunkt unten Mitte. Feste Reihenfolge: 0–3 Kronen, 4–5 Büsche, 6–7 Bäume mit Stamm (oberer Rand), 8 Schattenverlauf | 9 | M3 |
| `assets/tiles/forest_props.png` | Reihe aus 64×64-Zellen (Bäume, Felsen, Büsche; unten bündig). **Derzeit ungenutzt**, für Deko nach M7 | beliebig viele | M1 |
| `assets/ui/joystick_ring.png` | 32×32 | 1 | M2 |
| `assets/ui/joystick_knob.png` | 16×16 | 1 | M2 |
| `assets/ui/pause_button.png` | 16×16 | 1 | M2 |
| `assets/ui/debug_button.png` | 16×16 (nur Test-Builds, muss nicht ersetzt werden) | 1 | M3 |
| `assets/ui/panel.png` | 24×24 (9-Slice, Rand 8) – Steinrahmen mit Goldlinie und Nieten für Menüfenster | 1 | M2 |
| `assets/ui/slider_track.png` | 12×8 (9-Slice, Rand 3) – Schieberegler-Leiste | 1 | M2 |
| `assets/ui/slider_grabber.png` | 16×16 – Schieberegler-Knopf | 1 | M2 |
| `assets/sprites/enemies/skeleton_walk.png` | 32×32 (Pixellab) | 8 | M3 |
| `assets/sprites/characters/hero_hit.png` | 32×32 (Platzhalter vorhanden, Pixellab-Ersatz willkommen) | 2 (beliebig, läuft einmal durch) | M3 |
| `assets/sprites/characters/hero_death.png` | 32×32 (Platzhalter vorhanden, Pixellab-Ersatz willkommen) | 6 (beliebig, letzter Frame bleibt liegen) | M3 |
| `assets/ui/bar_frame.png` | 16×4 (Lebensleiste über dem Helden, im Spiel 2× skaliert) | 1 | M3 |
| `assets/ui/bar_fill.png` | 14×2 (sitzt 1 Pixel innerhalb des Rahmens) | 1 | M3 |
| `assets/sprites/weapons/magic_bolt.png` | 16×16, Blick nach **Osten** (Schweif links, wird in Flugrichtung gedreht). Platzhalter vorhanden (`tools/gen_weapon_placeholders.gd`) | 4 (beliebig) | M4 |
| `assets/sprites/effects/hit.png` | 32×32, Treffer-Funken in der Körpermitte des Gegners, mit dunklem 1-px-Rand für Lesbarkeit. Platzhalter vorhanden (`tools/gen_effect_placeholders.gd`), Pixellab-Ersatz willkommen | 4 (beliebig) | M4 |
| `assets/sprites/effects/death.png` | 32×32, Tod-Staub, Bild steht mit dem Unterrand auf den Füßen des Gegners. Platzhalter vorhanden, Pixellab-Ersatz willkommen | 6 (beliebig) | M4 |
| `assets/sprites/effects/damage_digits.png` | Ziffern 0-9 und „!“ der Schadenszahlen, je 10×12-Zelle (Körper 7×9, dicker Rand, Schatten unten rechts), hell, damit sie per Elementfarbe eingefärbt werden. Generator `tools/gen_damage_digits.gd` | 11 Zeichen | M4c |
| `assets/sprites/pickups/xp_crystal.png` | 16×16 | 4 | M6 |
| `assets/sprites/icons/weapon_<id>.png` (je Waffe, z. B. `weapon_arcane_wand.png`) | 32×32, zeigt **die Waffe selbst** (Zauberstab, Schwert, Dreizack, Fackel, Peitsche, Bombenbeutel), nicht ihren Angriff, Bildinhalt zentriert. Zauberstab vorhanden (Generator `tools/gen_weapon_icons.gd`, Final-Kandidat) | 1 | M4d |
| `assets/sprites/weapons/sword_orbit.png` | 32×32, Stahl-Kurzschwert waagerecht, Spitze nach Osten (wird im Spiel so gedreht, dass die Spitze vom Helden weg zeigt). Vorhanden (Generator `tools/gen_weapon_placeholders.gd`) | 1 | M4e |
| `assets/sprites/effects/aura_flame.png` | 16×16 je Frame, **eine** kleine Flamme, **Bildinhalt vertikal mittig im Frame** (Zeilen 2–13): Die Bildmitte steht auf der Ringlinie, die Flamme halb innerhalb, halb außerhalb des Trefferradius. Der Feuerring setzt sie im Kreis um die **Körpermitte** des Helden (Anzahl nach Umfang), so bleibt er bei jedem Radius pixelscharf. Vorhanden (Generator `tools/gen_effect_placeholders.gd`) | 4 | M4e |
| `assets/sprites/effects/lightning_strike.png` | 32×64 je Frame (hoch), gelb-weißer Zickzack-Blitz von oben, Fußpunkt (Einschlag) unten in der Mitte, Lichtfleck und Funken am Boden, ca. 0,7 s (10 fps), damit er im Getümmel auffällt. Vorhanden (Generator `tools/gen_effect_placeholders.gd`) | 7 | M4f |
| `assets/sprites/weapons/bomb.png` | 16×16 je Frame, Rundbombe (blaugrau, Lichtkante oben links, Messingkappe, Lunte). Frame 0 normal, Frame 1 rot glühend (blinkt kurz vor der Explosion immer schneller). Vorhanden (Generator `tools/gen_weapon_placeholders.gd`) | 2 | M4f |
| `assets/sprites/effects/whip_slash.png` | 106×54 je Frame, Peitschenhieb nach Osten, Drehpunkt (Held) bei (4, 27). Wächst über 4 Frames (45 %, 75 %, voll, verblassend), halbdurchsichtig, ohne Umriss. Vorhanden (Generator `tools/gen_effect_placeholders.gd`) | 4 | M4h |
| `assets/sprites/enemies/training_dummy.png` | 32×32, 1 Frame, Übungspuppe für das Debug-Menü (Holzpfahl, Strohsack, Sackleinen-Kopf mit X-Augen), Fußpunkt unten in der Mitte. Vorhanden (Generator `tools/gen_training_dummy.gd`) | 1 | M4g |
| `assets/sprites/effects/explosion.png` | 96×96 je Frame, Mitte = Explosionspunkt, passt zum Wirkradius 40: greller Kern, Feuerball, Rauchring. Die Warnfläche (dezent rot, füllt sich bis zur Explosion) zeichnet der `StrikeManager` im Code. Vorhanden (Generator `tools/gen_effect_placeholders.gd`) | 6 | M4f |
| `assets/sprites/effects/whip_slash.png` | Sichelform (lang, gekrümmt wie ein Swoosh), Blick nach Osten und wird für die 4 Himmelsrichtungen gedreht (Vorschlag: 64×32, mit Probebild abstimmen) | 3–4 | M4h |
| `assets/ui/card_frame.png` | 32×32 (9-Slice) | 1 | M6 |
| `assets/sprites/enemies/bat_fly.png` | 32×32 | 4 | M7 |
| `assets/sprites/enemies/slime_hop.png` | 32×32 | 4 | M7 |
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
- Versionsanzeige unten rechts im Hauptmenü (aus Projekteinstellungen → `application/config/version`, aktuell „Alpha v0.3“).
- Die Arena-Begrenzung durch Bäume, Büsche und Steine war vorläufig. **Seit M3 (nach der 32×32-Umstellung):**
  - Neuer Waldboden und ein **dichter Wald als natürliche Map-Grenze**.
  - Die begehbare Fläche ist unverändert 1152×768 (36×24 Kacheln), rundherum 5 Kacheln Wald.
  - Aufbau in `run.gd`: Ebenen `Ground`, `GroundDetails`, `Canopy`, `ForestEdge` (hinter den Figuren) und `ForestEdgeFront`
    (unterer Rand, vor den Figuren).
  - Der Rand besteht aus zufällig versetzten und gespiegelten Kronen, Büschen und Bäumen. Oben sieht man Stämme, dort schaut man von vorne in den Wald.
  - Die Props-Texturen werden anderweitig verwendet → Thema nach M7 (siehe dort).
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
  Knöpfe „Weiter“, „Optionen“ und „Run aufgeben“ (bis M8 geht der Run dabei verloren). „Run aufgeben“ muss zweimal
  angetippt werden („Wirklich aufgeben?“), damit man nicht versehentlich aufgibt.
  Zurück-Geste und Esc schließen immer nur das oberste offene Fenster (Optionen → Pause → weiterspielen).
  Die drei Status-Spalten (siehe „UI-Konzepte“) sind schon angelegt und füllen sich ab M3.
- **Auto-Pause:** Wechselt die App in den Hintergrund (andere App, Anruf), öffnet sich automatisch das Pausemenü.
  Bekannte Einschränkung: Das Herunterziehen der Benachrichtigungsleiste meldet Android/Godot auf dem Testhandy nicht,
  dort pausiert das Spiel nicht. Beim Testen mit Gegnern (M3) hat das gestört → **in M8 beheben**.
- **Am Handy testen:** Du kannst mit dem Daumen flüssig laufen, auch schräg. Probiere Modi, Seiten und Transparenz im Optionsmenü aus
  und sag mir, was sich am besten anfühlt. Schließ die App und öffne sie neu: Die Einstellungen sind noch da.
  Pause-Knopf und Zurück-Geste öffnen die Pause. Wechsle während eines Runs kurz in eine andere App:
  Beim Zurückkommen ist das Spiel pausiert.
  **Auf GitHub:** Prüfe auf der Repo-Startseite, ob die README gut aussieht und dir der Text gefällt.

### M3 – Gegner (mit Performance-Grundlage) + Debug-Menü-Grundgerüst

Umsetzung in Teilschritten: M3a Gegner erscheinen und verfolgen (EnemyManager, Grid, FPS-Anzeige) →
M3a+ Debug-Menü-Grundgerüst mit Zoom-Vergleich (aus M5 vorgezogen) → M3a++ dynamischer Zoom →
M3a+++ Debug-Knopf direkt im Run, Option „Spiel weiterlaufen lassen“ →
M3b Schaden, Lebensleiste, Game Over, SceneRouter → M3b+ I-Frames nach Schaden (`IFrameRule`), Selbstschaden →
Vergleichstest 16×16 / 32×32 → Umstellung auf 32×32 → neues Heldenmodell (Pixellab), vorübergehend max. 120 Gegner → Optionsmenü mit Kategorie-Reitern → M3c Bildschirmwackeln + Vibration (erledigt) →
M3d HP im Statusbildschirm, Gegner nach Höhe sortiert zeichnen, Treffer-/Tod-Animation des Helden (`hero_hit`, `hero_death`) (erledigt).

- Kontaktschaden nach „Grundsatzentscheidungen“ Punkt 5: Der Held läuft durch Gegner, Gegner bleiben an seinem Rand stehen.
  Im Debug-Menü: Regler für die I-Frames sowie Testknöpfe „Treffer 20 %“ und „Selbstschaden 10 %“.
- `EnemyManager` mit Pooling und Spatial Grid. Gegner (z. B. Skelett) erscheinen außerhalb des Sichtfelds und laufen auf den
  Helden zu, ohne sich alle auf einen Punkt zu stapeln.
- Bei Berührung nimmt der Held Schaden. Es gibt eine Lebensleiste, und bei 0 HP kommt ein Game-Over-Bildschirm mit den Knöpfen „Nochmal“ und „Hauptmenü“.
- **Lebensleiste über dem Helden** (Option „Lebensleiste Spieler“ an/aus).
- **Treffer-Feedback beim Helden:** kurzes Bildschirmwackeln und Vibration (Optionen „Bildschirmwackeln“ und „Vibration“).
  Stärke nach Trefferanteil an den max. HP (Wackeln über `RunCamera.shake()` mit 1,5–4 Welt-Pixeln, damit auch leichte Treffer sichtbar wackeln; Vibration 40–120 ms). Selbstschaden löst nichts aus.
  Die Android-Berechtigung VIBRATE ist in `export_presets.cfg` gesetzt.
  Vibriert wird über `scripts/haptics.gd`: Ab Android 13 direkt über die Android-Vibration mit der Kategorie „Medien“.
  Godots `Input.vibrate_handheld` zählt als Touch-Feedback und wird auf Handys mit ausgeschalteter Touch-Vibration verworfen
  (am Redmi getestet). Ältere Android-Versionen und der PC nutzen weiter den Godot-Weg.
- Statusbildschirm zeigt HP („Lebenspunkte: 80 / 100“, Charakter-Spalte).
- **Held-Animationen:** Treffer (`hero_hit`, läuft einmal durch, der Held kann dabei weiterlaufen) und Tod (`hero_death`, bleibt auf dem letzten Frame liegen).
  Beim Tod frieren die Gegner ein, das Game-Over-Fenster erscheint erst nach der Animation (+ 0,6 s). Die Platzhalter erzeugt `tools/gen_hero_placeholders.gd` aus `hero_idle.png`.
- FPS-Anzeige in der Ecke.
- **Am Handy testen:** Die Gegner kommen von außen herein und verfolgen dich. Du verlierst Leben, Game Over und Neustart funktionieren.
  Bei Treffern wackelt das Bild und das Handy vibriert. Beides und die Lebensleiste lassen sich in den Optionen abschalten.
  Notiere dir den FPS-Wert.

### M4 – Auto-Angriff

Umsetzung in Teilschritten: M4a Waffen-Architektur, Magiegeschoss, Geschoss-Pool, Gegner-HP mit Aufleuchten und Tod (**erledigt**, am PC getestet) →
**M4a+** (**erledigt**, am PC getestet, Handy-Test offen) Umbau für den Waffen-Baukasten (Zauberstab-Umbenennung `arcane_wand`, `WeaponContext`, Behavior-Haken, `TargetPicker`, `amount` mit Salve, stabile Gegner-IDs, Farbpalette aus den vorhandenen Texturen) →
M4b (**erledigt**, am PC und Handy getestet, FPS auf dem Redmi stabil bei vielen Gegnern, Geschossen und Effekten – das ist der Maßstab für die nächsten Schritte) Treffer- und Tod-Effekte (`hit.png`, `death.png`) mit allgemeinem `EffectManager` und Treffer-Formen (`damage_in_radius`, `damage_in_crescent`) →
M4c (**erledigt, am PC getestet; Feinschliff, sobald mehrere Waffen im Spiel sind**) Schadenszahlen und Gegner-Lebensleisten mit Optionen (Schadenszahlen in Elementfarbe) →
   `DamageNumberManager` (Pool 64, Bildschirm-Raum, eigene Ziffern-Grafik in Stufen 3/4/5, Crit mit „!“ und Ploppen, tödlich bleibt länger), Leisten nur bei verletzten Gegnern, Schalter in Anzeige, Debug „Test-Crit“. Signal `enemy_damaged(position, amount, element, crit, kill)`.
M4d (**umgesetzt, am PC und Handy getestet**) Statusbildschirm mit Waffen-Spalte (4 Plätze, Icon, Name, Fähigkeit) →
   Karte je Platz (Icon, Name, Element, Level-Leiste mit 10 Feldern, Werte), Antippen öffnet ein Detailfenster (Fähigkeit, alle Werte, Upgrades, Entwicklung, verursachter Schaden). Karte zeigt „Lv 4“ und dahinter die Entwicklungsstufe als Sterne (`EvolutionStars`, Stufen je Waffe `max_evolution`, Standard 3), im Detailfenster „Entwicklung“ mit denselben Sternen, oben rechts „Startwaffe“, unten rechts das Element, die wichtigsten Werte legt jede Angriffsart über `card_stats()` fest. `WeaponInstance.total_damage` zählt mit. Icon `weapon_arcane_wand.png` per Generator `tools/gen_weapon_icons.gd` (Ebenholzstab, goldene Mondsichel mit Kugel). →
M4e (**umgesetzt, am PC getestet**, Handy-Test der FPS bei vielen Gegnern offen) Kreisendes Schwert (`OrbitBehavior`) und Flammenfackel (`AuraBehavior`) →
   Schwert wie die Bibel in Vampire Survivors: Klingen erscheinen für `duration` (3 s) im Zyklus `cooldown` (5 s), +1 `amount` = weitere Klinge (gleichmäßig verteilt), `duration` ≥ `cooldown` = dauerhaft (Upgrade-Ziel, Wirkdauer ist auf den Zyklus begrenzt). Klingen sind Geschosse mit Bewegungsart ORBIT im `ProjectileManager`, treffen alle Gegner unter sich (`EnemyManager.find_all_in_radius`), denselben Gegner höchstens alle `hit_interval` (0,5 s, Treffer-Gedächtnis 16 je Klinge). Fackel: Puls alle `cooldown` (0,5 s) auf alle Gegner im Radius `range` (64), Feuer-Element. Radius (bis 160) und Takt (bis 0,2 s) sind die Upgrade-Ziele, Grenzen über `WeaponData.stat_limits`. Flammenring zeichnet der `AuraDrawer` (unter den Gegnern). Ring und Klingen zentrieren sich auf `Player.BODY_CENTER_HEIGHT` (15 px über den Füßen, Mitte des Held-Bildes), fliegende Geschosse und Gegner nutzen 14. Die Zentrierung ist per Messtest geprüft (Abweichung 0 Welt-Pixel bei Radius 64, 112 und 160). Debug: Schwert/Fackel hinzufügen, Test-Boni (Dauer, Radius, Takt). →
M4f (**umgesetzt, am PC getestet**, Handy-Test der FPS offen) Dreizack und Bombenbeutel (`StrikeBehavior`, Warnfläche) →
   `StrikeManager` (Pool, ein `_draw`, unter den Gegnern): Einschläge mit optionalem Bogenflug und Zünder, Warnfläche, dann `damage_in_radius` und Effekt. Dreizack: Blitz (Element Blitz) auf zufällige verschiedene Gegner im Bild (`RandomVisiblePicker`, `EnemyManager.pick_random` per Reservoir Sampling), überzählige Blitze auf zufällige Punkte im Bild, Wirkradius `area` 20 (bis 40). Bombenbeutel: Feuer, Bogenwurf 0,5 s auf zufällige Gegner bis 160 px (`RandomInRangePicker`), zielt mit `EnemyManager.predict_position` dorthin, wo der Gegner beim Auslösen steht, Zünder `fuse` 1 s (bis 0,5), Radius `area` 40 (bis 80). `WeaponBehavior.on_removed` + `WeaponHolder.clear_run_weapons` (Debug „Run-Waffen entfernen“, später für Evolutionen). →
M4g (**umgesetzt, am PC getestet**, Werte werden später gebalanced) Elemente und Status-Effekte →
   `StatusEffectData` (data/status: Brennen 20/0,5 s 3 s auffrischen, Gift 8/0,5 s pro Stapel bis 10 Stapel 4 s, Schock = Kettenblitz 30 % auf bis zu 2 Gegner im Umkreis 64 für 4 s, Frost 40 % langsamer 3 s). Speicher im `EnemyManager` als Bitmaske + flache Arrays (`MAX_STATUS` 4), nur Gegner mit Maske laufen durch die Status-Schleife. Kettenblitz über das Spatial Grid, löst keine weiteren Ketten aus, gelbe Zickzack-Linie. Anzeige: Tönung in Elementfarbe (wechselt bei mehreren Status), zustandslose Pixel-Partikel, DoT-Ticks als kleine Zahlen (Stufe 2) ohne Aufblitzen/Funken (Signal `enemy_damaged` mit `dot`). `ApplyStatusEffect` (WeaponEffect) vorbereitet, **noch keiner Waffe zugeordnet** (Entscheidung: Status vorerst nur per Debug). Debug-Menü mit Reitern (Allgemein, Waffen, Gegner, Status): Gegner-LP ×1/×5/×20, +100 Gegner, Gegner entfernen, Übungspuppe (`training_dummy`: unsterblich, verankert, heilt 2 s nach dem letzten Treffer), Status geben (160 px). →
M4h (**umgesetzt, am PC getestet**) Dornenpeitsche (`SweepBehavior`) und Grundlage für Welle/Ricochet. Jede Stufe liefert eine spielbare Waffe als Beweis, dass die Architektur das Muster trägt.
   Hieb wie in Vampire Survivors (Referenz-Screenshot des Nutzers): lange, leicht geschwungene Bahn gerade vom Helden weg, dünn und durchscheinend am Helden, nach außen dicker, Spitze rollt sich nach oben ein, wächst und verblasst (`whip_slash.png`, nach links gespiegelt). Treffer: `EnemyManager.damage_in_strip` (Länge `range` 90, Upgrades bis 180, halbe Breite `area` 12, bis 24, ab 8 px neben dem Helden; auf Wunsch des Nutzers klein gehalten, damit Platz für Größen-Upgrades bleibt). Richtungen: erste zufällig aus 4, dann Gegenseite → „+“ → Diagonalen (max. 8 Hiebe, gleichzeitig). Kein Ricochet für die Peitsche (nur für Waffen, die schießen/werfen). **Ricochet** = Geschoss-Stat `ricochet` im `ProjectileManager` (prallt nach dem letzten Durchschlag zum nächsten Gegner ab, nie zurück zum vorigen), **Welle** = unbegrenzter Durchschlag (`pierce`). Debug: „Peitsche hinzufügen“, „Zauberstab: +1 Abpraller“, „Zauberstab: Durchschlag ∞“. `EffectManager.play` kann jetzt drehen, spiegeln, strecken und hat den Anker `PIVOT`.

- Erste Waffe **Arkaner Zauberstab** (sein Angriff ist das „Magiegeschoss“; bis M4a noch unter dem Namen „Magiegeschoss“ geführt): Sie schießt automatisch auf den nächsten Gegner. Geschosse kommen aus einem Pool.
  Gegner haben HP, blinken kurz bei einem Treffer und sterben (mit kleinem Effekt).
- Waffen-Architektur nach Grundsatz 9: `WeaponData` (Datendatei `data/weapons/*.tres`, Stats als Liste „ID → Wert“, `behavior`, `effects`),
  `WeaponInstance` (Zustand im Run, `get_stat()`), `WeaponHolder` (4 Plätze: `START_SLOTS` 1 + `RUN_SLOTS` 3) und `ProjectileManager` (Geschoss-Pool).
  Zielmodus der Waffe: `NEAREST` ist umgesetzt, `FACING` folgt mit der ersten Waffe, die ihn braucht.
- Waffen sind ein eigener Baustein (Node `Weapons`), den die Run-Szene dem Helden anhängt. `player.gd` bleibt waffenfrei.
- Der Zauberstab ist vorerst die **feste Startwaffe** (im Debug-Menü später wählbar). Die Run-Szene liest dafür eine einzelne Startwaffen-ID (`START_WEAPON_ID` in `run.gd`, vorerst fest
  vorgegeben), ohne Auswahl-Logik. Die Auswahl im Hub kommt mit E10.
- Gegner sterben erst zu Beginn des nächsten Frames (`EnemyManager.damage()` markiert, `_remove_dead()` entfernt) und senden dann `enemy_killed` (Anschluss für M4b/M6).
- Geschosse fliegen in der Fußebene und werden 14 Pixel höher (Körpermitte) gezeichnet, damit sie zu den Kollisionskreisen an den Füßen passen.
- **Effekte (M4b):** `EffectManager` (Pool, ein Zeichenaufruf, Datendatei `EffectData` in `data/effects/`) spielt Treffer-Funken (bei jedem Schaden, über das Signal
  `EnemyManager.enemy_damaged`) und Tod-Staub (bei `enemy_killed`) ab. Dazu die Treffer-Formen `damage_in_radius` und `damage_in_crescent` (Sichel) im `EnemyManager`,
  die Bomben, Blitze, Aura und Peitsche später nutzen.
- **Schadenszahlen** über getroffenen Gegnern (Option „Schadenszahlen“), aus einem Pool.
- **Schadens-Regel (entschieden in M4h):** Waffen, die mehrere Gegner treffen, machen nie mehr Grundschaden als Waffen, die weniger Gegner treffen. Heute: Zauberstab 50 (1 Gegner) · Dreizack 45 · Schwert 40 · Peitsche 35 · Bomben 30 · Fackel 15 (Fläche, Dauerschaden).
- **Schadens-Skala und Streuung (entschieden nach M4f):** Alle Schadens- und Gegner-LP-Werte ×10 (Skelett 100 LP, Zauberstab 50, Schwert 60, Fackel 30, Dreizack 100, Bomben 150), Balance unverändert. Jeder Treffer streut ±10 % (`EnemyManager.DAMAGE_SPREAD`) und wird auf ganze Zahlen gerundet, damit die Zahlen lebendig wirken; Karten zeigen den Durchschnitt. `EnemyManager.damage()` und die Flächen-Treffer liefern den tatsächlich verursachten Schaden (Schadenszähler der Waffen). Crits (Chance, Schaden) kommen erst mit dem Werte-System (M6).
- **Lebensleisten über Gegnern** (Option „Lebensleisten Gegner“). Sie erscheinen nur bei bereits verletzten Gegnern und
  werden alle in einem einzigen Zeichenaufruf des EnemyManagers gezeichnet, nicht als eigene Nodes. Das ist wichtig für die Performance.
- Statusbildschirm zeigt die Waffe mit ihren Werten.
- **Am Handy testen:** Der Held schießt von allein, Treffer und Tode sind gut zu erkennen, und das Spiel fühlt sich an wie ein Survivor-Like.
  Schadenszahlen und Gegner-Lebensleisten lassen sich einzeln abschalten.

### M5 – Debug-Menü erweitern, Stresstest & Optimierung

**M5b (umgesetzt, am Handy bestätigt: 800 Gegner fast 60 FPS, max. 30–40 ms):** Erste Messung am Redmi: bis 500 Gegner über 50 FPS und unter 20 ms, bei 800 Gegnern ruckelig (max. ~50 ms). PC-Profil: Zeichnen ~1 ms, aber die Abstandsberechnung zwischen Nachbarn in `EnemyManager._move` 7,4 ms bei 800 Gegnern. Umbau: Abstandsprüfung in `_separation_push()` mit lokalen Arrays, Radius je Gegner in `_radii` statt aus den Gegnerdaten, Rasterzellen 24 statt 32 px (weniger Kandidaten), `find_hit` sucht nach Reichweite statt fest 3×3 Zellen. Genau übereinanderliegende Gegner bekommen eine feste Ausweichrichtung (blieben vorher für immer gestapelt). Ergebnis PC bei 800 Gegnern: 5,1 statt 7,4 ms. **Verworfen** (mit Zitter-Messung `m5_jitter.gd` geprüft): jedes Paar nur einmal mit gleichzeitigem Schub (zittert bzw. drückt die Masse auf ~11 statt 20 px Abstand zusammen), alten Schub jedes zweite Frame wiederverwenden (springt), nur halbe Gegner pro Frame ausweichen lassen (wackelt sichtbar). Die Gegner weichen weiter nacheinander aus, das bleibt ruhig. Nächste Stufe, falls nötig: Zeichnen per MultiMesh, oder ein Gegner-Limit auf dem Bildschirm.

**M5a (umgesetzt):** Werkzeuge für den Stresstest: „Unverwundbar“ (Reiter Allgemein, `Player.debug_invincible`), „Startwaffe wechseln“ (Reiter Waffen, reihum alle 6 Waffen, `WeaponHolder.replace_start_weapon`), Leistungsanzeige oben links: FPS, durchschnittliche und längste Bildzeit der letzten ~2 s (ms, die längste zeigt Ruckler), Anzahl Gegner, Geschosse/Einschläge und Effekte. PC-Vorabtest: 500 Gegner (LP ×20) mit 4 Waffen (je +2 Projektile) bei stabilen 60 FPS (Vsync-Grenze). **M5b:** Messung am Redmi in 100er-Schritten, danach gezielt optimieren.

- **Debug-Menü** (nur in Debug-Builds sichtbar, also beim Testen aus Godot, nicht in einem späteren Release).
  Das Grundgerüst gibt es schon seit M3: erreichbar über den Debug-Knopf neben dem Pause-Knopf, das Spiel kann dabei weiterlaufen
  (Zoom, I-Frames). Das Fenster ist scrollbar: Neue Einträge kommen in den Scrollbereich, Titel und „Zurück“ bleiben fest.
  Neu: „+100 Gegner“, „Unverwundbar“, **„Startwaffe wählen“, „Waffe geben“, „Status geben“** (zum Testen aller Waffen und Status, bis die Startwaffen-Auswahl im Hub mit E10 kommt).
  Es wächst mit: in M6 „XP geben“ und „Level-Up auslösen“,
  in M7 „Zu Welle X springen“, später z. B. „Magie-Schrott geben“.
- Mit „+100 Gegner“ messen, wie viele Gegner dein Handy bei stabilen 60 FPS schafft.
  Bei Bedarf optimieren, z. B. mit MultiMesh-Rendering oder einem gröberen Grid.
- Prüfpunkt: Flimmern beim dynamischen Zoom mit vielen Gegnern und mit echten Alpha-Assets erneut ansehen. Held und Gegner haben
  den Sharp-Pixel-Shader schon. Flimmern Boden oder Props sichtbar, bekommen sie ihn auch (dann Kachel-Atlas mit Abstand zwischen den Kacheln).
- Zielwert: mindestens **500 gleichzeitige Gegner bei 60 FPS** auf dem Testhandy **Redmi Note 13 4G** (Snapdragon 685 / Adreno 610 GPU, Display 2400×1080 = 20:9).
  Das ist untere Mittelklasse: Läuft es dort flüssig, läuft es auf den meisten Handys.
  Den Wert passen wir nach der Messung an.
- **Am Handy testen:** Spawne immer mehr Gegner und sag mir, ab welcher Anzahl es ruckelt und wie warm das Handy wird.

### M6 – XP & Level-Up

**Entscheidungen (2026-11-13):** XP-Kristalle sind **Seelensplitter, Farbe nach Wert** (blau klein, grün mittel, rot/violett groß, leichtes Funkeln). Einsammeln mit **Sammelradius, Kristalle fliegen dann beschleunigend zum Helden**; liegen sehr viele herum, verschmelzen die ältesten zu einem großen. XP-Kurve **schnell am Anfang** (wie Vampire Survivors). Level-Up: **3 Karten nebeneinander** (Icon, Name, „Neu“ bzw. „Lv 3 → 4“, Wertänderung). HUD: **XP-Leiste unten mittig** (halbe Bildschirmbreite, Stufe rechts darin; zuerst oben quer probiert, wirkte zu voll), oben links **Lebensleiste** (Herz, Blutrot) und die **4 Waffenplätze** (nur Anzeige). XP in Seelenblau.

Schritte: **M6a** HUD-Grundgerüst · **M6b** XP-Kristalle, Sammelradius · **M6c** Werte-System (StatBlock, Modifikatoren) · **M6d** Level-Up-Karten und Upgrade-Pools · **M6e** Statusbildschirm.

**M6c (umgesetzt, getestet):** Werte-System in `scripts/stats/`: `StatModifier` (Stat-ID, Art FLAT/PERCENT/MULT, Wert, optional `required_tags`) und `StatBlock` (Sammlung, Signal `changed`, Rechnung `(Grundwert + Σ FLAT) × (1 + Σ PERCENT) × Π MULT`). Jede `WeaponInstance` hat einen eigenen Block (`modifiers`, Upgrades) und liest den globalen Block `RunState.stats` mit, aber nur für Stats, die ihre Angriffsart versteht (`supports_stat`, z. B. kein „+1 Projektil“ für die Aura). Ergebnisse werden pro Waffe zwischengespeichert, bis sich ein Bonus ändert (kein Leistungsverlust bei 800 Gegnern). Grenzen wie bisher über `stat_limits` und `limit_stat`. Held: Grundwerte `base_speed`, `base_max_hp`, `base_pickup_radius`, geltende Werte aus Stat-IDs `move_speed`, `max_hp`, `pickup_radius` (steigen die Max-HP, steigen die HP mit). Debug (Reiter Waffen, „Globale Boni“): +10 % Schaden, −10 % Abklingzeit, +1 Projektil (alle), +20 % Lauftempo, +20 Max-HP, +20 Sammelradius, Zurücksetzen, Anzeige der Heldenwerte. Eigene Stat-Definitionen als Datendateien (Min/Max je Stat, Anzeige-Name) folgen, sobald Spielerwerte wie Rüstung, Krit oder Ausweichen dazukommen; bis dahin reichen `stat_limits` der Waffen und feste Untergrenzen beim Helden.

**M6b (umgesetzt, getestet):** `PickupManager` (Pool in gepackten Arrays, ein `_draw`, unter Aura und Gegnern): Gegner lassen beim Tod `EnemyData.xp_value` als Seelensplitter fallen (Skelett 1, Übungspuppe 0). Größe nach Wert: klein blau (1–2), mittel grün (ab 3), groß violett (ab 10). Im Sammelradius (`Player.pickup_radius`, 40 Welt-Pixel) springt der Splitter kurz zurück und fliegt dann beschleunigend zum Helden. Höchstens 400 liegen gleichzeitig, darüber wandert neue Erfahrung in den am weitesten entfernten Splitter. Grafik `tools/gen_pickups.gd` (`assets/sprites/pickups/xp_crystal.png`, 3 Zeilen × 4 Frames, Funkeln). Debug (Allgemein): „Alle Splitter anziehen“, „+300 Splitter verstreuen“. FPS-Anzeige zählt die Splitter mit.

**M6a (umgesetzt, am Handy bestätigt):** `RunState` (Stufe, XP, Signale `xp_changed`/`leveled_up`, nur im Run), `XpCurve` (`data/progression/xp_curve.tres`: 5 XP für Stufe 2, danach +10 je Stufe, ab Stufe 20 +13, ab 40 +16). HUD in `ui/hud/`: `HudRoot` (verbindet Anzeigen per `bind_hud`; Pause-/Debug-Knopf und FPS-Anzeige hängen mit daran; **keine Safe-Area-Einrückung**: am Redmi wirkte das HUD dadurch schief bzw. zu weit im Bild, die Kamera liegt im Querformat links auf halber Höhe), `XpDisplay`, `HealthDisplay` (Signal `Player.hp_changed`), `WeaponSlots` (Signal `WeaponHolder.weapons_changed`, Startwaffe mit Goldrand). Grafiken `tools/gen_hud.gd`. FPS-Anzeige unter die Waffenplätze gerückt. Debug (Allgemein): „+ halbe Stufe XP“, „Stufe +1“ (Level-Up vorerst ohne Karten).

- **Zuerst das HUD-Grundgerüst** nach „UI-Konzepte → HUD“: HUD-Szene mit Bereichen, feste HP-Leiste, XP-Leiste, Level und Waffen-Icons.
- Gegner lassen XP-Kristalle fallen, die per Magnet eingesammelt werden. Am oberen Rand gibt es eine XP-Leiste.
- Beim Level-Up pausiert das Spiel, und es erscheinen **3 Karten** zum Antippen, gezogen aus einem Pool: eine neue Waffe (nur solange
  ein Run-Platz frei ist, nie eine schon vorhandene) oder ein Upgrade einer vorhandenen Waffe (auch der Startwaffe).
- Die **6 Start-Waffen** (Zauberstab, Schwert, Dreizack, Fackel, Peitsche, Bombenbeutel) sind spielbar, jede mit eigenem Upgrade-Pool (`WeaponUpgrade`, siehe Grundsatz 9).
  Der Pool zieht nur aus freigeschalteten Waffen (zunächst `default_unlocked`).
- Erster Effekt-Upgrade **Ricochet** (abprallende Geschosse) für den Zauberstab. Er beweist, dass Effekte ohne Umbau dazukommen (Grundsatz 9).
- **Werte-System** nach „Grundsatzentscheidungen“ Punkt 6: Stat-Definitionen, Modifikatoren und StatBlock.
  Level-Up-Upgrades sind Modifikatoren. Kommt Ausweichen dazu: Ein ausgewichener Treffer gibt die Mindestdauer der I-Frames.
- Statusbildschirm zeigt Level, XP, alle Waffen-Slots mit Level und Werten sowie die Spielerwerte.
- **Am Handy testen:** Kristalle werden eingesammelt, das Level-Up-Menü lässt sich gut antippen und die Karten sind lesbar.
  Mit 4 Waffen kommen keine neuen Waffen mehr, sondern nur noch Upgrades.

### M7 – Wellen & Run-Ende

- Wellen-Timer (z. B. 60 s) mit Anzeige, z. B. „Welle 3 / 10“. Die Gegner werden pro Welle stärker und zahlreicher.
- **Erfahrung wächst mit den Wellen** (Wunsch aus M6b, im Genre üblich): Spätere Wellen bringen stärkere Gegnertypen mit höherem `xp_value`, dazu ein XP-Faktor je Welle in den Wellen-Daten (wie der HP-Faktor). So bleiben grüne und violette Splitter später häufiger und die steigende XP-Kurve wird ausgeglichen. Genaue Werte beim Balancing.
- **Kamera:** `RunCamera.reset_wave()` beim Wave-Start (zurück auf 3×). Zoomstufen und Grenze von 50 Gegnern bleiben fest (siehe Grundsatzentscheidung 2).
- **Spawn-Muster:** Neben zufälligen Spawns gibt es Formationen wie Ringe und Einkesselung. Sie werden mathematisch berechnet
  und in den Wellen-Dateien (`Resource`) festgelegt, nicht im Code.
- Zwischen den Wellen gibt es einen Platzhalter-Rastplatz: eine Pause mit Wellen-Zusammenfassung und „Weiter“-Knopf.
  Die echten Händler kommen später.
- Nach der letzten Welle erscheint ein Sieg-Bildschirm, bei Tod ein Game-Over-Bildschirm. Beide zeigen die
  **Run-Zusammenfassung (Basis)** (siehe „UI-Konzepte“) und führen zurück ins Hauptmenü.
- Statusbildschirm zeigt Welle, Zeit und Kills.
- **Am Handy testen:** Ein kompletter Run lässt sich durchspielen, gewinnen und verlieren. Ist die Länge von 10–15 Minuten angenehm?
  Stimmen die Zahlen in der Zusammenfassung?
- ⚠ **Erinnerung nach Abschluss von M7:** Die neue Map-Abgrenzung (dichter Wald) ist seit M3 eingebaut. Offen bleibt:
  Wofür die Props-Texturen (`forest_props.png`: Bäume, Felsen, Büsche) stattdessen verwendet werden, z. B. als Deko oder Hindernisse in der Map.

### M8 – Run speichern & fortsetzen

- Die genaue technische Umsetzung planen wir zu Beginn von M8. Diese Grundsätze stehen schon fest:
  - Im Pausemenü wird „Run aufgeben“ ergänzt durch **„Speichern & Hauptmenü“**. Im Hauptmenü erscheint **„Fortsetzen“**,
    wenn ein Run gespeichert ist.
  - **Autosave nach jeder abgeschlossenen Welle** (beim Betreten des Rastplatzes).
  - **Autosave, wenn die App in den Hintergrund geht.** Android kann Apps im Hintergrund jederzeit beenden.
  - **Pause beim Herunterziehen der Benachrichtigungsleiste** nachrüsten (meldet Godot auf dem Testhandy bisher nicht, siehe M2).
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

- ⚠ **Erinnerung nach Abschluss von M8:**
  - README gemeinsam aktualisieren und deine ersten Screenshots einbauen.

➡ **Nach M8 ist das Grundspiel fertig.**

## UI-Konzepte

### HUD (im Run)

Modular aufgebaut, damit sich Anzeigen leicht ergänzen, ändern und entfernen lassen. **Gebaut wird es zu Beginn von M6**, wenn die ersten
festen Anzeigen gebraucht werden. Ein zentrales Datensystem fürs HUD selbst gibt es bewusst nicht: Jede Anzeige braucht ohnehin eigenen Code,
und Szenen lassen sich im Editor direkt sehen und verschieben.

- **Jede Anzeige ist eine eigene kleine Szene** in `ui/hud/`. Neue Anzeige = neue Szene, Entfernen = Szene löschen.
- **Bereiche in der HUD-Szene:** oben links, oben Mitte, oben rechts, unten links, unten rechts. Position ändern = in einen anderen Bereich ziehen.
- **Anzeigen lauschen auf Signale** (z. B. `hp_changed`) und fragen nicht in jedem Frame ab, das schont den Handy-Prozessor.
- **Spiel-Systeme kennen das HUD nicht.** Deshalb lässt sich jede Anzeige gefahrlos entfernen.
- **Safe Area** (Kamera-Notch) wird nur einmal zentral in der HUD-Wurzel behandelt.
- **Berührungen:** Reine Anzeigen lassen sie durch, damit der Joystick nicht blockiert wird. Knöpfe kommen in die Gruppe `joystick_blocker`.
- **Daten nur dort, wo Listen wachsen:** Waffen-Slots und Ressourcen lesen Icon und Namen aus den Datendateien.

| Wann | Anzeigen |
| --- | --- |
| M6 | Feste HP-Leiste (die Leiste über dem Helden bleibt zusätzlich abschaltbar), XP-Leiste, Level, Waffen-Icons |
| M7 | Welle, Zeit, Kills |
| E1 / E3 / E5 | Magie-Schrott / Spezialfähigkeit mit Abklingzeit / Materialien |

### Pause-/Statusbildschirm (im Run)

Drei Spalten, damit im Querformat alles auf einen Blick sichtbar ist:

| Links: Charakter | Mitte: Waffen | Rechts: Ausrüstung & Run |
| --- | --- | --- |
| HP, Level, XP-Fortschritt | 4 Waffen-Slots (Startwaffe markiert): Icon, Level x/10, Evolutionsstufe und gewählter Zweig | **Paperdoll** mit angelegter Rüstung |
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

- **Kategorien als Reiter oben.** Alle Kategorien und Optionen stehen nur in `scripts/options_catalog.gd`. Das Menü baut
  Reiter und Zeilen daraus selbst (Typen: An/Aus, Auswahl-Knöpfe, Schieberegler, siehe `scripts/option_def.gd`).
  Kategorie hinzufügen, verschieben oder löschen heißt also eine Zeile im Katalog ändern. Kategorien ohne Optionen werden ausgeblendet.
- Kategorien: Steuerung, Anzeige, Grafik, Audio, Allgemein.

| Bereich | Option | Kommt in |
| --- | --- | --- |
| Steuerung | Joystick-Modus (Floating / Fest) | M2 |
| Steuerung | Joystick-Seite (Links / Rechts / Beide) | M2 |
| Steuerung | Joystick-Transparenz (Schieberegler) | M2 |
| Steuerung | Vibration an/aus | M3 |
| Anzeige | Lebensleiste Spieler an/aus | M3 |
| Anzeige | Bildschirmwackeln an/aus | M3 |
| Anzeige | Schadenszahlen an/aus | M4 |
| Anzeige | Lebensleisten Gegner an/aus | M4 |
| Audio | Lautstärke Gesamt / Musik / Effekte | E2 |
| Allgemein | Sprache Deutsch / Englisch | E14 |
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

## Hub-Stadt

Die Stadt, die man nach und nach wieder aufbaut, ist ein **begehbarer Ort** und das Zentrum des Spiels, kein reines Menü.

- **Einstieg:** Der Held erwacht im Wald → Intro-Level als Tutorial (E11) → am Ende entdeckt er eine zerstörte Dorf-Ruine,
  die als Hub freigeschaltet wird.
- **Eigenes Haus:** von Anfang an vorhanden, betretbar, dient als **Lager**.
- **Gebäude als Daten** (`BuildingData`): Zustände (Ruine → Stufe 1 → 2 …) mit Grafik je Zustand, Freischalt-Bedingungen
  (Materialien, Quests), Innenraum-Szene. Die Stadt-Karte hat feste Bauplätze und liest beim Betreten aus dem Profil-Spielstand,
  welcher Zustand gilt. Ein neues Gebäude ist also vor allem eine neue Datendatei und eine Innenraum-Szene.
- **Betretbare Gebäude:** Wiederaufgebaute Gebäude und das eigene Haus haben einen **eigenen Innenraum** (kleine eigene Szene,
  geladen über den `SceneRouter`). Durch die Tür hinein, beim Hinausgehen steht man wieder vor der Tür (Spawn-Marker).
  Drinnen stehen NPCs bzw. Objekte, die die Menüs öffnen (z. B. Amboss beim Schmied, Lagertruhe im Haus). Ruinen sind nicht betretbar.
- **NPCs als Daten** (`NpcData`): Dialog-Texte (Übersetzungs-Schlüssel), Bedingungen, was sie anbieten.
- **NPC für Spezialfähigkeiten** (Platzhalter `[Lehrmeister]`, Gebäude noch offen): schaltet neue Spezialfähigkeiten frei
  (Kosten stehen in den Fähigkeitsdaten) und lässt die aktive Fähigkeit wechseln. Wechseln geht nur hier, also vor einem Run.
- **Interaktion:** In die Nähe laufen → ein Knopf („Sprechen“, „Betreten“ …) erscheint.
- **Übergang zu Expeditionen:** Stadttor bzw. Expeditionstafel → Map-Auswahl → Run. Nach dem Run: Zusammenfassung → zurück in den Hub.
- Der Hub hat nur wenige Objekte, die Performance-Regeln für Gegnermassen gelten dort nicht in derselben Strenge.

## Erweiterungen (Alpha, nach M8)

Reihenfolge nach technischen Abhängigkeiten. Details planen wir jeweils zu Beginn.

1. **E1 – Rastplätze mit Händlern:** zufällige Händler (Tränke, Artefakte), Währung „Magie-Schrott“. Braucht Wellen (M7) und Speichern (M8).
2. **E2 – Audio:** Musik und Soundeffekte, Lautstärke-Optionen.
3. **E3 – Spezialfähigkeit:** aufladbar, Knopf rechts, Anzeige im Statusbildschirm. Eine erste Fähigkeit als Datendatei
   (`SpecialAbilityData`), damit weitere ohne Code-Umbau dazukommen. Freischalten und Wechseln kommt erst mit E10.
4. **E4 – Waffen-Evolutionen:** Level 10 → 1 von 3 Varianten → 2. Evolution → 1 von 3 = 9 Endformen.
   Eine Evolution ist eine neue Waffen-Datendatei (andere Werte, Effekte, Verhalten), die die alte im selben Platz ersetzt.
5. **E5 – Meta-Spielstand + Belohnungsbildschirm:** Profil-Spielstand (`profile.save`), Material-Register und erste Materialien
   aus Runs, volle Run-Zusammenfassung.
6. **E6 – Begehbare Hub-Stadt** (siehe „Hub-Stadt“). Ab hier startet das Hauptmenü in den Hub statt direkt in einen Run.
   - **E6a Grundgerüst:** Stadt begehen, eigenes Haus (betretbar, Lager), Stadttor/Expeditionstafel → Run → zurück in den Hub.
   - **E6b Ausbau:** Gebäude wieder aufbauen (Schmied, Alchemist, Enchanter …) und betreten, NPCs, Story-Dialoge.
7. **E7 – Rüstungssystem mit Paperdoll:** im Dorf kaufen, verbessern und über die Paperdoll anlegen, im Run ansehen.
8. **E8 – Permanente Upgrades** über Dorf-Gebäude.
9. **E9 – Questsystem:** Quest-Items und Questfortschritt, Anzeige im Belohnungsbildschirm.
10. **E10 – Spezialfähigkeiten und Startwaffen freischalten und wählen:** NPC `[Lehrmeister]` im Hub für Fähigkeiten,
    Auswahl der Startwaffe vor der Expedition (Ort klären wir mit E6, z. B. Expeditionstafel). Mehrere Fähigkeiten und
    Startwaffen, Speicherung im Profil. Braucht E3, E5 und E6b. (Ersetzt die frühere Idee „mehrere spielbare Charaktere“.)
11. **E11 – Intro-Level / Tutorial:** Der Held erwacht im Wald, das erste Level bringt schrittweise die Grundlagen bei
    (die erste Waffe materialisiert sich in höchster Not). Am Ende entdeckt er die Dorf-Ruine, die zum Hub wird.
    Braucht Level-Up, Rastplatz, Spezialfähigkeit und den Hub. Den Inhalt besprechen wir vorher gemeinsam.
12. **E12 – Weitere Maps/Biome, Gegnertypen, Bosse.**
13. **E13 – Endlos-Modus** nach der letzten Welle. Brotato verkürzt dort die I-Frames, bei uns ginge das über eine eigene `IFrameRule`.
14. **E14 – Englisch** + Sprach-Option.
15. **E15 – Erweiterte Optionen:** Joystick-Größe, FPS-Limit.
16. **E16 – Credits-Bildschirm.** Ab dem ersten fremden Asset führen wir `CREDITS.md` mit Quelle und Lizenz,
    damit am Ende nichts fehlt.

- **Laufend:** Ersetzt werden nur Dateien mit dem Status „Platzhalter“ (siehe „Assets“), sobald du bessere Grafiken hast.

## Beta (vor der Veröffentlichung, nicht Teil der Alpha)

- **Monetarisierung** entscheiden (Einmalkauf, Werbung, In-App-Käufe oder kostenlos). Das beeinflusst das Design, z. B. ob es
  „Wiederbeleben gegen Werbung“ gibt.
- **Play-Store-Pflichten:** App-Icon, Datenschutzerklärung (Pflicht, auch ohne Werbung), Altersfreigabe, Store-Texte, Screenshots.
- **Endgültiger Spielname**, dann Paketname (`com.slydee23.…`) und App-Namen im Export-Preset anpassen.
  Nach dem ersten Upload lässt sich der Paketname nie mehr ändern.

## Ideen (noch nicht eingeplant)

- **Headstart-Perk:** Ein Teil des Magie-Schrotts aus dem vorherigen Run wird in den nächsten Run mitgenommen.
  Wie und ob das ins Spiel kommt, ist noch offen.
- **Schwebende Waffen:** Die Waffen schweben als Icons um den Spieler (wie bei Brotato). Vorerst werden Waffen nicht am Helden gezeichnet.
- **Homing als Upgrade-Effekt** für Geschosse (Lenken im Flug) und **Elementreaktionen** (z. B. Feuer + Kälte).
- **Sichtbare Rüstung:** späteres Update, das angelegte Rüstung an der Spielfigur zeigt, mit Option an/aus.
- **Rastplatz als begehbarer Ort:** Händler-Karawane als NPCs, die man ansprechen kann (nutzt die Hub-Interaktion).
- **Frei verschiebbares HUD:** Der Spieler ordnet Anzeigen selbst an, ließe sich später als gespeichertes Layout ergänzen.
- **Spezialfähigkeit im Run wechseln:** eventuell über einen besonderen Encounter zwischen zwei Wellen.
  **Nicht entschieden**, deshalb nicht umsetzen und keine Systeme darauf ausrichten.

## UI-Stil: „Runenstein & Bann-Siegel“

- **Feedback zu M2c:** Pausemenü, Status-Screen und Buttons wirkten kantig und nicht modern. Am 2026-11-11 auf Wunsch des Nutzers
  vorgezogen und umgesetzt (statt erst nach M8).
- **Stil (vom Nutzer gewählt):** dunkler Runenstein mit Goldkante, violetter Magie-Schimmer, passend zur Lore (Bann des Hohen Zirkels,
  Waffen zerfallen zu Staub). Gedrückte/gewählte Knöpfe glühen violett. Titel und Überschriften in Gold mit Schlagschatten.
- **Hauptmenü-Bild:** Nacht über einem Schlachtfeld voller zerfallender Klingen, Bögen und Speere (Staub steigt auf), der Held steht
  dazwischen, über dem Mond liegt das Siegel des Zirkels. Alles als Pixel-Art von `tools/gen_ui.gd` erzeugt (auch alle UI-Texturen);
  der Nutzer kann jede Datei durch eigene Pixellab-Assets (gleicher Name, gleiche Größe) überschreiben.
- **Schrift:** Jersey 10 (OFL; ersetzt Pixelify Sans, deren „5“ wie ein „S“ aussah). Größen nur 32, 48, 64, 96, 128 verwenden (`PixelUI.FONT_SIZE_*`), dann bleibt sie scharf.
  Statt Umrandung gibt es einen Schlagschatten (Theme `shadow_offset`).
- **Umfang:** Theme (Knöpfe, Fenster, Regler, Reiter), Hauptmenü, Pause, Optionen, Game Over, HUD-Knöpfe. Das Debug-Menü erbt nur das Theme.
  Joystick und Lebensleiste sind noch im alten Stil (Kandidaten für später).
- Technisch hängt die Optik an den UI-Texturen und den Theme-Werten in `scripts/pixel_ui.gd` (`make_theme()`); der Menü-Code blieb
  weitgehend unberührt.

## Offene Designfragen

- ~~Sprite-Auflösung 16×16 oder 32×32~~ → **entschieden: 32×32, Figurengröße 1,5×** (siehe „Technische Grundentscheidungen“).
  ~~Lizenz der Pixellab-Assets~~ → geklärt: Rechte liegen bei uns (Pixellab-Nutzungsbedingungen 1.3), siehe `CREDITS.md`.
  Ob die Figuren bei vielen Gegnern groß genug wirken, prüfen wir beim Testen. Feinwerte (Zoom, Geschwindigkeiten) beim Balancing.
- **Menü-Schrift:** gelöst, Jersey 10 ersetzt Pixelify Sans (Vergleich mit Silkscreen, Press Start 2P, Micro 5, VT323, Jacquard 12). Idee für später: Jacquard 12 (Fraktur-Pixelschrift, OFL) nur für große Überschriften/Titel ausprobieren.
- **Waffen-Baukasten, noch offen** (jeweils vor der betreffenden Stufe klären):
  - ~~Shock-Effekt~~ → **entschieden: Kettenblitz** (Slow gehört zu Frost). Konkrete Werte (Anteil des Schadens, Anzahl Ziele, Reichweite) vor M4g.
  - **Dreizack-Icon:** Dem Nutzer fehlt noch ein klarer Blitz-Hinweis (ein Zickzack an der Spitze wirkte wie eine Kerzenflamme, jetzt nur dezente gelbe Runen am Schaft). Später neu überlegen.
  - **Schadenszahlen bei Flächenschaden** (Bomben, Aura) überlappen bei vielen Treffern. Feinschliff, sobald mehrere Waffen getestet sind (siehe M4c).
  - ~~Überzählige Geschosse~~ → **entschieden:** Zauberstab = Salve reihum auf die gewählten Ziele, Dreizack = zufälliger Punkt im Bild (Dreizack vor M4f noch einmal ansehen).
  - ~~Peitschen-Richtung~~ → **entschieden:** zufällig aus den 4 Himmelsrichtungen, zusätzliche Schläge gegenüber → „+“ → Diagonalen (max. 8). Länge der Sichel mit Probebild abstimmen (vor M4h).
  - **Salve-Abstand** (jetzt 0,1 s, `ProjectileBehavior.SALVO_DELAY`) und **Größe der Bomben-Warnfläche** am Handy abstimmen.
  - Weitere Entwicklungen und Freischalt-Quellen der Waffen im Dorf → mit E4/E10.
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
