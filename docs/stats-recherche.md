# Stats-Recherche für E1 (Stand 2026-11-21)

Sammlung möglicher Helden-Werte (Stats) als Grundlage für unsere gemeinsame Auswahl.
**Nichts hiervon ist über die bereits bestätigten Stats hinaus freigegeben.**

Bewertung in der letzten Spalte:

- ★★★ passt sehr gut zu Banebound
- ★★ interessant, aber nicht vorrangig
- ★ eher nicht (redundant, schwer zu balancieren oder unnötig komplex)

Inspirationsquellen: Vampire Survivors (VS), Brotato (BR), Halls of Torment (HoT), Soulstone Survivors (SS),
Risk of Rain 2 (RoR), Diablo/Path of Exile (ARPG). **Eigene Idee** ist entsprechend markiert.

---

## 0. Was es schon gibt

Diese Werte stecken bereits im Werte-System (`StatModifier`/`StatBlock`) und müssen nicht neu erfunden werden.

| Stat | Wo |
|---|---|
| Max-HP, Lauftempo, Sammelradius | Held (Shop-Boni) |
| Schaden %, Abklingzeit %, Projektile (+1) | alle Waffen (Shop-Boni) |
| Wirkradius, Reichweite, Dauer, Geschosstempo, Durchschlag, Abpraller, Zündzeit | einzelne Waffen (Level-Up-Upgrades) |

Wichtig für später: Viele „neue“ Stats aus anderen Spielen (z. B. VS *Area*, *Duration*, *Speed*) haben wir schon pro Waffe.
Die Frage ist dort nur, ob es zusätzlich eine **globale** Version für alle Waffen geben soll.

---

## 1. Bereits bestätigte Stats

| Name | Kategorie | Funktion | Gameplay-Auswirkung | Mögliche Verwendung | Inspiration |
|---|---|---|---|---|---|
| **Armor / Rüstung** | Defensiv | Verringert jeden Treffer: Reduktion = Rüstung ÷ (Rüstung + K), z. B. K = 15 (15 Rüstung = −50 %, 30 = −67 %, nie 100 %) | Gegen viele kleine Treffer (Horden) sehr wirksam, die Formel schützt vor Unverwundbarkeit | Hauptwert der Rüstungsteile (E8), Shop-Bonus, Dorf-Upgrade, Evolutionen von Nahkampfwaffen (z. B. „Schwert gibt Rüstung pro Klinge“) | VS, BR |
| **Dodge / Ausweichen** | Defensiv | Chance, einen Treffer ganz zu vermeiden, Obergrenze z. B. 60 %. Ausgewichen = kurze I-Frames (steht schon im Plan) | Glücksbasierte Verteidigung, gut gegen große Einzeltreffer (Boss-Stampfer, Feuerball) | Leichte Rüstungsteile, Lauftempo-Builds, Evolution „Schatten…“ | BR, HoT (Evasion) |
| **Health Regeneration / Lebensregeneration** | Defensiv | Heilt X Leben pro Sekunde (bzw. alle 5 s, damit kleine Werte lesbar bleiben) | Zwischen Wellen und Gefahren „durchatmen“, belohnt Ausweichen statt Tanken | Rüstung, Shop, Dorf (Kräuterhütte), Tränke als kurzer Schub | VS (Recovery), BR |
| **Critical Strike Chance / Krit-Chance** | Offensiv | Chance, dass ein Treffer kritisch ist | Spitzen im Schaden, sichtbar als große Schadenszahl (Anzeige gibt es schon) | Waffen mit Basis-Krit (z. B. Zauberstab), Evolutionen „Krit löst Effekt aus“, Ringe/Amulette | BR, HoT, RoR |
| **Critical Strike Multiplier / Krit-Schaden** | Offensiv | Wie viel stärker kritische Treffer sind (Start z. B. ×1,5) | Lohnt erst mit Krit-Chance, ergibt einen echten „Krit-Build“ | Seltene Boni, Evolutionen, Rüstungs-Sets | BR, HoT, ARPG |
| **Luck / Glück** | Utility | Verschiebt Zufall zu deinen Gunsten: Seltenheiten beim Level-Up und im Shop, später Drops und Händler | Langfristig wertvoll, kurzfristig unsichtbar (spannende Abwägung) | Seltenheit (`Rarity.roll`), Krit-Chance als kleiner Nebeneffekt?, Material-Drops (E6) | VS, BR |

---

## 2. Vorschläge aus anderen Spielen

### Offensiv

| Name | Funktion | Gameplay-Auswirkung | Mögliche Verwendung | Inspiration | Bewertung |
|---|---|---|---|---|---|
| **Elemental Damage / Elementarschaden** (je Element: Feuer, Blitz, Gift, Frost) | +% Schaden für Waffen eines Elements | Belohnt Waffen mit gleichem Element, passt perfekt zu unseren 5 Elementen und Tags | Rüstungsteile „Feuer-Set“, Element-Evolutionen, Dorf (Enchanter) | BR (Elemental Damage) | ★★★ |
| **Melee / Ranged Damage / Nah- und Fernkampfschaden** | +% Schaden für Waffen mit Tag `melee` bzw. `projectile` | Zwei klare Build-Richtungen, nutzt vorhandene Tags | Waffen-Tags, Rüstung, Evolutionen | BR | ★★ (überschneidet sich mit Elementarschaden, eins von beiden reicht anfangs) |
| **Status Power / Effektstärke** | Stärkere bzw. längere Status-Effekte (Brennen, Gift-Stapel, Kettenblitz, Frost) | Macht Element-Waffen zu eigenen Builds statt reinem Grundschaden | Gift-Evolutionen, Alchemist im Dorf | SS, BR (Burning) | ★★★ |
| **Duration / Wirkdauer (global)** | +% Dauer aller Waffen mit Dauer (Schwert, später Flächen) | Wenige Waffen profitieren, sonst totes Upgrade | Nur als Waffen-Upgrade lassen | VS | ★ (haben wir pro Waffe) |
| **Area / Wirkfläche (global)** | +% Radius aller Flächenwaffen | Großer Spaßfaktor, aber Leistung am Handy (mehr Treffer je Frame) beachten | Später als seltener Bonus | VS | ★★ |
| **Projectile Speed / Geschosstempo (global)** | +% Tempo aller Geschosse | Eher Komfort, kaum Build-Entscheidung | Waffen-Upgrade reicht | VS (Speed) | ★ |
| **Knockback / Rückstoß** | Treffer stoßen Gegner zurück | Gibt Raum zum Atmen, macht Peitsche/Schwert besonders; gegen Bosse begrenzen | Peitschen-/Schwert-Evolution, Rüstung „Bollwerk“ | BR, VS | ★★★ (hilft den schwachen Nahkampfwaffen) |
| **Multistrike / Mehrfachschlag** | Chance, dass ein Angriff sofort ein zweites Mal ausgelöst wird | Sehr starker Multiplikator (wirkt wie +Projektile) | Seltene Evolution statt allgemeiner Stat | HoT | ★ (gefährlich: wir haben gerade Projektile gedeckelt) |
| **Boss / Elite Damage / Schaden gegen Bosse** | +% Schaden gegen Bosse und Elite-Gegner | Lohnt erst mit mehr Bossen/Elites, Gegenmittel zu „Boss zu schwach/zu stark“ | Waffen-Evolutionen, Quest-Belohnungen | BR | ★★ (später, mit Elites) |
| **Life Steal / Lebensraub** | Chance, pro Treffer 1 Leben zu heilen | Heilung über Angriff statt über Zeit, starkes Gegenstück zu Regeneration | Vampir-Set, Blut-Evolution | BR | ★★ (bei vielen Treffern pro Sekunde leicht zu stark, nur als Chance) |
| **Execute / Hinrichten** | Gegner unter X % Leben sterben sofort | Gut gegen Bosse/Elites mit viel Leben | Sense-Waffe, Evolution | ARPG (Culling Strike) | ★★ |

### Defensiv

| Name | Funktion | Gameplay-Auswirkung | Mögliche Verwendung | Inspiration | Bewertung |
|---|---|---|---|---|---|
| **Block / Blocken** | Chance, einen festen Wert vom Treffer abzuziehen | Dritte Verteidigungsart neben Rüstung und Ausweichen | Schild-Rüstungsteil | HoT (Block Strength) | ★ (redundant zu Rüstung/Ausweichen) |
| **Barrier / Schild** | Lädt sich auf, fängt den nächsten Treffer bzw. X Schaden ab, lädt nach einiger Zeit ohne Treffer neu | Belohnt sauberes Spiel, gut gegen den einen tödlichen Treffer | Rüstungsteil, Spezialfähigkeit (E4), Evolution | RoR (Personal Shield) | ★★★ |
| **Healing Power / Heilwirkung** | +% auf jede Heilung (Regeneration, Lebensraub, Tränke) | Verstärkt einen Heil-Build | Alchemist, Priester-Rüstung | ARPG | ★★ |
| **Thorns / Dornen** | Gegner, die dich treffen, erleiden Schaden | Passive Verteidigung, sehr passend für Tank-Builds | Dornen-Rüstung, Peitschen-Evolution („Dornenpeitsche“) | ARPG | ★★ |
| **Resistances / Resistenzen** (Feuer, Gift …) | Weniger Schaden von einem Element | Kultist (Feuer) und Pestbringer (Gift) gibt es schon, später Biome mit eigenen Elementen | Rüstungsteile, Biome (E13) | ARPG | ★★ (erst mit mehr Element-Gegnern) |
| **Revival / Wiederbelebung** | Einmal pro Run nach dem Tod wieder aufstehen | Sicherheitsnetz für lange Runs | Dorf-Upgrade oder Relikt (Museum) statt Stat | VS | ★★ (als Freischaltung, nicht als Stat) |

### Utility

| Name | Funktion | Gameplay-Auswirkung | Mögliche Verwendung | Inspiration | Bewertung |
|---|---|---|---|---|---|
| **Growth / Erfahrungsbonus** | +% Erfahrung | Mehr Level-Ups, frühe Investition, späte Belohnung | Shop, Dorf | VS, BR (XP Gain) | ★★ |
| **Greed / Seelenbonus** | +% Seelen pro Kill | Mehr Shop-Käufe, „Investieren statt Kämpfen“ | Shop, Dorf, Händler (E2) | VS (Greed) | ★★★ (Shop hat jetzt eine Währung) |
| **Harvesting / Ernte** | Am Rastplatz feste Seelen, die jede Welle etwas wachsen | Langfristige Investition, Gegenstück zu „alles sofort ausgeben“ | Shop-Bonus, Händler-Kauf | BR (Harvesting) | ★★ |
| **Curse / Fluch** | Mehr und stärkere Gegner, dafür mehr Erfahrung/Seelen | Freiwilliges Risiko, ideal für erfahrene Spieler und den Endlos-Modus | Relikte, Schwierigkeits-Wahl, Endlos-Modus (E14) | VS (Curse) | ★★★ (passt zum Lore-Fluch „Waffenbann“) |
| **Rerolls / Skips / Banish** | Mehr Neu-Würfeln/Überspringen, „Bannen“ entfernt eine Karte für den Rest des Runs | Mehr Kontrolle über den Build | Laut Plan über **Relikte im Museum** freischalten | VS | ★★★ (bereits halb geplant) |
| **Shop Discount / Händlerrabatt** | −% Preise im Shop und bei Händlern | Kleine Wirtschafts-Variante | Händler (E2) | BR (Items Price) | ★ (zu wenig spürbar) |

---

## 3. Eigene Ideen (Eigene Idee)

Ziel: Stats, die zu **Banebound** (Waffenbann, Seelen, Wellen mit Rastplatz) passen und Probleme aus den Tests lösen,
z. B. „kein Grund sich zu bewegen“.

| Name | Kategorie | Funktion | Gameplay-Auswirkung | Mögliche Verwendung | Bewertung |
|---|---|---|---|---|---|
| **Momentum / Schwung** | Offensiv/Bewegung | Solange du läufst, steigt der Schaden bis +X %, im Stehen fällt er langsam ab | Löst direkt das Feedback „kein Grund sich zu bewegen“ | Leichte Rüstung, Läufer-Evolutionen | ★★★ |
| **Steadfast / Standhaftigkeit** | Defensiv | Im Stehen mehr Rüstung | Gegenstück zu Schwung, ermöglicht „Festungs“-Builds mit Fackel/Schwert | Schwere Rüstung | ★★ (nur zusammen mit Schwung sinnvoll) |
| **Desperation / Verzweiflung** | Offensiv, niedrige HP | Je weniger Leben, desto mehr Schaden (z. B. bis +50 % bei 10 % Leben) | Risiko-Spiel, starke Comebacks | Blut-Rüstung, Berserker-Evolution | ★★★ |
| **Last Stand / Letztes Aufbäumen** | Defensiv, niedrige HP | Einmal pro Welle überlebst du einen tödlichen Treffer mit 1 Leben und kurzer Unverwundbarkeit | Verzeiht Fehler, ohne den Run zu entwerten | Relikt, Amulett | ★★★ |
| **Soul Resonance / Seelenresonanz** | Offensiv/Wirtschaft | +1 % Schaden je X gesparte Seelen (nicht ausgegebene) | Spannende Entscheidung am Rastplatz: kaufen oder horten | Seelen-Evolutionen, Kultisten-Thema | ★★★ (passt zum Lore, nutzt vorhandene Währung) |
| **Bloodrush / Blutrausch** | Offensiv | Kills geben kurz stapelbares Angriffstempo | Belohnt Kill-Ketten, fühlt sich in Horden toll an | Peitsche/Schwert-Evolutionen | ★★ |
| **Elemental Harmony / Elementar-Einklang** | Offensiv | +% Schaden je weitere Waffe mit demselben Element | Fördert thematische Builds („nur Feuer“) | Waffenwahl, Evolutionen mit Element-Bedingung | ★★ (überschneidet sich mit Elementarschaden) |
| **Overkill / Überschuss** | Offensiv | Überschüssiger Schaden eines tödlichen Treffers springt auf einen Gegner in der Nähe | Starke Einzeltreffer bleiben auch gegen schwache Horden nützlich | Bomben, Schwert-Evolution | ★★ |
| **Proximity / Nähe** | Offensiv | +% Schaden gegen Gegner in deiner Nähe (bzw. Gegenstück Distanz) | Positionsspiel: Nahkampf-Builds gehen bewusst ran | Peitsche, Fackel, Schwert | ★★ |
| **Wave Rhythm / Wellenatem** | Defensiv | Zu Beginn jeder Welle X Sekunden Schild und volle Regeneration | Passt zum Wellen-Rhythmus, entschärft harte Starts | Relikt, Dorf | ★ (eher Belohnung als Stat) |

---

## 4. Eher nicht (vorerst)

- **Block:** dritte Verteidigungsart neben Rüstung und Ausweichen, macht das Lesen der Werte schwerer.
- **Multistrike als allgemeiner Stat:** verdoppelt Waffenausstoß wie „+Projektile“, die wir gerade gedeckelt haben. Besser als seltene Evolutions-Eigenschaft.
- **Globale Dauer/Geschosstempo:** helfen nur wenigen Waffen. Besser bleiben sie Waffen-Upgrades.
- **Händlerrabatt:** kaum spürbar, Greed/Harvesting decken Wirtschaft besser ab.

---

## 5. Technische Überlegungen

So bleibt das System erweiterbar, ohne die vorhandene Architektur umzubauen:

1. **Stat-Definition als Datendatei** (`StatDefinition`-Resource): ID, Name/Beschreibung (Übersetzung), Kategorie, Grundwert,
   Minimum/Maximum (Caps wie Ausweichen 60 %), Anzeigeformat („+5 %“, „12“), ob er auf den Helden oder auf Waffen wirkt.
   Ein neuer Stat ist dann vor allem eine neue Datei. Die Anzeige im Pausemenü kann sich daraus selbst bauen.
2. **Alle Quellen liefern Modifikatoren** (wie schon heute: FLAT/PERCENT/MULT mit Tags). Level-Up, Shop, Rüstung, Evolutionen,
   Dorf, Relikte und Status-Effekte sind nur unterschiedliche Lieferanten in denselben `StatBlock`.
3. **Bedingte Stats** (Schwung, Verzweiflung, Seelenresonanz) als **Bedingungs-Modifikator**: Faktor wird nur bei Ereignissen
   neu berechnet (Leben ändert sich, Seelen ändern sich, Laufen beginnt/endet), nicht jeden Frame. Das bleibt handyfreundlich.
4. **Treffer-Effekte** (Krit, Lebensraub, Hinrichten, Rückstoß, Dornen) laufen über **eine zentrale Schadensfunktion**.
   Dort wird einmal gewürfelt und berechnet, statt in jeder Waffe einzeln. Bei 800 Gegnern wichtig: keine neuen Arrays, nur Zahlen.
5. **Glück** greift an genau definierten Stellen (Seltenheits-Würfel, später Drops), nicht „überall ein bisschen“.
   So bleibt es nachvollziehbar.
6. **Waffen/Evolutionen verknüpfen** über Tags und Bedingungen in den Daten, z. B. „Evolution verlangt 20 % Krit-Chance“
   oder „Schwert erhält Rüstung als Schaden“. Dafür braucht es nur lesenden Zugriff auf den fertigen Wert.

---

## 6. Meine Empfehlung für die Auswahl

Neben den sechs bestätigten Stats würde ich diese als nächstes ernsthaft prüfen:

1. **Elementarschaden** (je Element), nutzt Elemente und Tags, die es schon gibt.
2. **Effektstärke** (Status-Effekte), damit Gift, Feuer und Frost eigene Builds werden.
3. **Rückstoß**, hilft gezielt Peitsche und Schwert.
4. **Schild/Barriere**, die beliebteste Verteidigung im Genre.
5. **Seelenbonus (Greed)**, passt zum Shop.
6. **Fluch**, Risiko gegen Belohnung, passt zur Lore.
7. **Schwung**, löst das Bewegungs-Problem.
8. **Verzweiflung** und **Letztes Aufbäumen** als Niedrig-HP-Paar.
9. **Seelenresonanz**, eigenständige Banebound-Idee.

Danach (mit mehr Gegnertypen, Händlern und Rüstung): Lebensraub, Dornen, Resistenzen, Boss-Schaden, Erfahrungsbonus, Ernte.

---

## Quellen

- [Brotato Wiki – Stats](https://brotato.wiki.spellsandguns.com/Stats)
- [Brotato Wiki – Secondary Stats](https://brotato.wiki.spellsandguns.com/Secondary_stat)
- [GamePressure – Brotato: all stats explained](https://www.gamepressure.com/newsroom/brotato-all-stats-harvesting-and-engineering-explained/z04b5e)
- [Vampire Survivors Wiki – PowerUp](https://vampire-survivors.fandom.com/wiki/PowerUp?oldid=2256)
- [Vampire Survivors Wiki – Curse](https://vampire-survivors.fandom.com/wiki/Curse)
- [Halls of Torment: Swordsman-Build (Werte wie Block Strength, Defense)](https://commonsensegamer.com/halls-of-torment-best-swordsman-build/)
- [Halls of Torment: Charaktere (Multistrike)](https://fantasywarden.com/?p=21995)
- Weitere Ideen (Risk of Rain 2, Soulstone Survivors, ARPGs) aus eigener Genre-Kenntnis, nicht eigens recherchiert.
