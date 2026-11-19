class_name EnemyAbility
extends Resource
## Besonderes Verhalten eines Gegnertyps (Sprungangriff, Fernzauber, Platzen, Boss-Schlag), wie WeaponBehavior bei den Waffen.
## Hängt an EnemyData.ability. Normale Gegner haben keine und kosten dadurch nichts extra.
## Der EnemyManager ruft update() in seiner Bewegungsschleife auf. Der Zustand liegt in seinen Arrays
## (ability_state, ability_time, ability_timer, ability_vec), nicht in der Ressource: Eine Ressource gilt für alle
## Gegner dieses Typs.

## Zustände, die alle Fähigkeiten nutzen können (0 = normal laufen)
const STATE_CHASE := 0
const STATE_WINDUP := 1
const STATE_ACTION := 2
const STATE_RECOVER := 3


## Ein Frame für Gegner i. Rückgabe true = die Fähigkeit hat Bewegung und Pose übernommen (kein normales Verfolgen,
## kein Wegschieben durch Nachbarn), false = normal weiterlaufen.
func update(_manager: EnemyManager, _i: int, _data: EnemyData, _target: Player, _delta: float) -> bool:
	return false


## Warnflächen am Boden (z. B. Schlagfläche des Bosses). Der EnemyManager ruft das vor dem Zeichnen der Gegner auf,
## nur für Gegner, deren Fähigkeit gerade nicht im Normalzustand ist.
func draw_ground(_manager: EnemyManager, _i: int, _data: EnemyData, _canvas: CanvasItem) -> void:
	pass


## Der Gegner stirbt (vor dem Entfernen). Z. B. Platzen beim Tod.
func on_death(_manager: EnemyManager, _i: int, _data: EnemyData) -> void:
	pass
