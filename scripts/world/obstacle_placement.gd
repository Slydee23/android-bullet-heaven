class_name ObstaclePlacement
extends Resource
## Ein fest platziertes Hindernis einer Karte (immer an derselben Stelle, z. B. eine markante Felsgruppe).

@export var kind: ObstacleKind
## Position in Welt-Pixeln relativ zur linken oberen Ecke der begehbaren Fläche
@export var position := Vector2.ZERO
