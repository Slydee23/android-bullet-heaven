class_name WaveSet
extends Resource
## Alle Wellen einer Expedition in Reihenfolge (data/waves/forest_run.tres). Die letzte Welle ist die Boss-Welle.

@export var waves: Array[WaveData] = []

@export_group("Schwierigkeits-Regler (gelten für alle Wellen)")
## Gegnermenge: Höchstzahl gleichzeitiger Gegner und Spawn-Tempo (1 = wie in den Wellen, 0.5 = halb so viele, 1.5 = die Hälfte mehr)
@export_range(0.1, 3.0, 0.05) var enemy_amount_scale := 1.0
## Lebenspunkte der Gegner und Bosse (Grundwert, gilt in jeder Welle)
@export_range(0.1, 5.0, 0.05) var enemy_hp_scale := 1.0
## Schaden der Gegner am Helden in Welle 1 (Grundwert, gilt in jeder Welle)
@export_range(0.1, 5.0, 0.05) var enemy_damage_scale := 1.0
## Steilheit: Um wie viel wachsen Lebenspunkte bzw. Schaden von Welle zu Welle, aufeinander aufbauend (0.2 = jede Welle +20 % gegenüber der vorigen,
## also ca. ×7 in Welle 12). Der Held wird durch Level-Ups, Shop und Evolutionen ebenfalls „mal-mal“ stärker, deshalb wachsen die Gegner so mit.
## Spiel zu leicht? Wert erhöhen. Zu schwer? Senken. 0 = gleich bleibend.
@export_range(0.0, 1.0, 0.01) var enemy_hp_growth := 0.2
@export_range(0.0, 1.0, 0.01) var enemy_damage_growth := 0.09
## Erfahrung je Gegner
@export_range(0.1, 5.0, 0.05) var xp_scale := 1.0
## Seelen je Kill (Währung des Rastplatz-Shops)
@export_range(0.1, 5.0, 0.05) var soul_scale := 1.0


## Lebenspunkte-Faktor einer Welle (Nummer ab 1): Wellenfaktor × Grundwert × Wachstum
func hp_factor_for(wave_number: int, wave: WaveData) -> float:
	return wave.hp_factor * enemy_hp_scale * pow(1.0 + enemy_hp_growth, wave_number - 1)


## Schaden-Faktor einer Welle (Nummer ab 1)
func damage_factor_for(wave_number: int, wave: WaveData) -> float:
	return wave.damage_factor * enemy_damage_scale * pow(1.0 + enemy_damage_growth, wave_number - 1)
