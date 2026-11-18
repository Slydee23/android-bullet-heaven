class_name LevelUpOffer
extends RefCounted
## Eine Karte im Level-Up-Fenster: neue Waffe, Waffen-Upgrade, Helden-Bonus oder Heilung (wenn nichts anderes mehr geht).

enum Kind { NEW_WEAPON, WEAPON_UPGRADE, HERO_UPGRADE, HEAL }

var kind := Kind.HEAL
## Neue Waffe: ihre Datendatei
var weapon_data: WeaponData
## Waffen-Upgrade: die Waffe im Run
var weapon: WeaponInstance
## Waffen-Upgrade und Helden-Bonus
var upgrade: UpgradeData
var rarity := Rarity.COMMON
